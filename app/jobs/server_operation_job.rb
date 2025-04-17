class ServerOperationJob < ApplicationJob
  queue_as :default

  def perform(server, operation)
    case operation
    when 'start'
      start_server(server)
    when 'stop'
      stop_server(server)
    else
      server.update(status: 'error')
      server.server_logs.create(level: 'error', message: "Unknown operation: #{operation}", timestamp: Time.current)
    end
  end

  private

  def start_server(server)
    # Server settings
    File.write(server.config_file_path, server.server_settings.to_json)

    # Prepare environment variables
    env_vars = [
      "RCON_PASSWORD=#{server.rcon_password}"
    ]

    # Only add SAVE_NAME if a save file is specified
    if server.save_file.present?
      env_vars << "SAVE_NAME=#{server.save_file}"
      env_vars << "LOAD_LATEST_SAVE=false"
      server.update(save_file: nil) # Clear save_file after use
    end

    space_age_dlc = "space-age"
    elevated_rails_dlc = "elevated-rails"
    quality_dlc = "quality"

    # Add DLC flags based on server settings
    dlc_flags = []
    dlc_flags << space_age_dlc if server.enable_space_age
    dlc_flags << elevated_rails_dlc if server.enable_elevated_rails
    dlc_flags << quality_dlc if server.enable_quality
    dlc_string = dlc_flags.join(' ')
    if dlc_string.empty?
      env_vars << "DLC_SPACE_AGE=false"
    else
      env_vars << "DLC_SPACE_AGE=#{dlc_string}"
    end

    env_vars << "RCON_PORT=#{server.rcon_port}"
    env_vars << "PORT=#{server.port}"
    env_vars << "TOKEN=#{server.user.factorio_token}" if server.user.factorio_token.present?
    env_vars << "UPDATE_MODS_ON_START=true" if server.auto_update_mods

    # Use specified version or default to latest
    version = server.version.present? ? server.version : 'latest'

    # Pull the image first to ensure it exists
    begin
      Docker::Image.create('fromImage' => "factoriotools/factorio:#{version}")
    rescue => e
      server.update(status: 'error')
      server.server_logs.create(
        level: 'error',
        message: "Failed to pull Docker image factoriotools/factorio:#{version}: #{e.message}. Make sure this version exists on Docker Hub.",
        timestamp: Time.current
      )
      return
    end

    # Create Docker container
    container = Docker::Container.create(
      'name' => server.container_name,
      'Image' => "factoriotools/factorio:#{version}",
      'Hostname' => "factorio-#{server.id}",
      'ExposedPorts' => {
        "#{server.port}/udp" => {},
        "#{server.rcon_port}/tcp" => {}
      },
      'HostConfig' => {
        'Binds' => [
          "#{server.server_directory}:/factorio",
        ],
        'PortBindings' => {
          "#{server.port}/udp" => [{ 'HostPort' => server.port.to_s }],
          "#{server.rcon_port}/tcp" => [{ 'HostPort' => server.rcon_port.to_s }]
        },
        'RestartPolicy' => {
          'Name' => 'always'
        }
      },
      'Env' => env_vars
    )

    # Start the container
    container.start

    server.update(docker_container_id: container.id, status: 'running')
    server.server_logs.create(level: 'info', message: "Server started with version #{version}", timestamp: Time.current)

    # Clear existing game logs
    server.game_logs.delete_all

    # Start log synchronization
    StreamGameLogsJob.perform_later(server.id)

  rescue => e
    server.update(status: 'error')
    server.server_logs.create(level: 'error', message: "Failed to start server: #{e.message}", timestamp: Time.current)
  end

  def stop_server(server)
    return unless server.docker_container_id.present?

    begin
      # Cancel game logs streaming
      StreamGameLogsJob.cancel_by(server_id: server.id) if defined?(StreamGameLogsJob.cancel_by)

      container = Docker::Container.get(server.docker_container_id)
      container.stop
      container.delete(force: true)
      server.update(docker_container_id: nil, status: 'stopped')
      server.server_logs.create(level: 'info', message: 'Server stopped', timestamp: Time.current)
    rescue Docker::Error::NotFoundError
      # Container already deleted, just update status
      server.update(docker_container_id: nil, status: 'stopped')
      server.server_logs.create(level: 'warn', message: 'Container not found, marked as stopped', timestamp: Time.current)
    rescue => e
      server.update(status: 'error')
      server.server_logs.create(level: 'error', message: "Failed to stop server: #{e.message}", timestamp: Time.current)
    end
  end

end