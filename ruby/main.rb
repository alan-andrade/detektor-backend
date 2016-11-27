require 'sinatra'
require 'json'
require 'open3'
require 'pry'

$cache = {}

before do
  headers "Access-Control-Allow-Origin" => "*"
end

get '/findKey' do
  url = params[:url]

  if !$cache[url]
    command = "youtube-dl '#{url}' -x --audio-format mp3 --exec '~/dev/keyfinder-cli/keyfinder-cli -n camelot'"
    logger.info command
    Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
      exit_status = wait_thr.value
      logger.info exit_status
      unless exit_status.success?
        status 406
        message = stderr.readlines.last.strip
        logger.info message
        body({error: message}.to_json)
        return
      end

      output = stdout.readlines
      key = output.last.strip
      logger.info key
      $cache[url] = key
    end
  end

  response = {key: $cache[url]}
  body response.to_json
end
