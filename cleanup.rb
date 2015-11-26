#!/usr/bin/env ruby
require 'pp'
require 'json'
require 'logger'
require 'date'
require 'time'
require 'yaml'


class ArtifactoryCleanUp

  $logger = Logger.new(STDOUT)


  def initialize(from)
    @artifactory_url = "https://my-artifactory-installation.com/artifactory"
    @username        = "johndoe"
    @password        = "johndoe"
    @from            = from # "1448023003000" # Timestamp (javaEpochMillis) in milliseconds: 1448195803000 (22 Nov 2015 12:36:43)
  end


  def artifacts_2_delete(repo, to)
    $logger.info("artifacts_2_delete: #{repo} | FROM: #{@from} TO:#{to}")
    JSON.parse(`curl -s -X GET -u #{@username}:#{@password} "#{@artifactory_url}/api/search/creation?from=#{@from}&to=#{to}&repos=#{repo}"`)
  end

  def validate_uri(uri)
    artifact_name = uri.split('/').last
    artifact_path = uri.gsub(/api\/storage\//,'').gsub(/http/,'https')
    return artifact_path, artifact_name
  end

  def convert_days_to_epoch(days)
    to_date = Time.now - (days * 86400)
    to_date.to_i * 1000
  end

  def delete_artefacts(artifacts)
    artifacts.each do |artifact|
      artifact['results'].each do |a|
        artifact_path, artifact_name = validate_uri(a['uri'])
        $logger.info("delete #{artifact_name} from REPO [created: #{a['created']}.to_date]")
        `curl -X DELETE -u #{@username}:#{@password} #{artifact_path}`
      end
    end
  rescue
    $logger.error('There are no artifacts in the given time range')
  end

  def cleanup_data
    $logger.info("cleanup_data")
    a2d = []
    YAML.load_file('./data/artifactory_cleanup.yaml').each do |vertical, values|
      values.each do |days, repos|
        repos.each do |repo|
          a2d << artifacts_2_delete(repo, convert_days_to_epoch(days))
        end
      end
    end
    a2d
  end

  def run
    a2d = cleanup_data
    delete_artefacts(a2d)
  end

end

ArtifactoryCleanUp.new('1416911260000').run
