# frozen_string_literal: true

require_relative 'integration_helper'

FIXTURES_PATH = File.expand_path('fixtures', __dir__)

RSpec.describe 'GitHub Action', :integration do
  let(:image_name) { 'verselicious-integration' }
  let(:project_root) { File.expand_path('../..', __dir__) }

  before(:all) do
    project_root = File.expand_path('../..', __dir__)
    system("docker build --load -t verselicious-integration #{project_root}", out: File::NULL, err: File::NULL)
  end

  def run_action(fixture:, env: {}, workspace: nil)
    fixture_path = File.join(FIXTURES_PATH, fixture)
    workspace ||= project_root
    default_env = {
      'GITHUB_WORKSPACE' => '/github/workspace',
      'GITHUB_REPOSITORY' => 'test-owner/test-repo',
      'GITHUB_SHA' => 'abc123',
      'GITHUB_EVENT_NAME' => 'pull_request',
      'GITHUB_EVENT_PATH' => '/github/event.json',
      'INPUT_GITHUB-TOKEN' => 'fake-token',
      'INPUT_MAJOR-LABEL' => 'major',
      'INPUT_MINOR-LABEL' => 'minor',
      'INPUT_PATCH-LABEL' => 'patch',
      'INPUT_TAG-PREFIX' => 'v',
      'INPUT_TARGET-BRANCH' => 'main',
      'INPUT_GENERATE-NOTES' => 'true'
    }.merge(env)

    env_flags = default_env.map { |k, v| "-e #{k.shellescape}=#{v.shellescape}" }.join(' ')

    command = "docker run --rm --add-host=host.docker.internal:host-gateway #{env_flags} " \
              "-v #{fixture_path}:/github/event.json:ro " \
              "-v #{workspace}:/github/workspace " \
              "#{image_name} 2>&1"

    `#{command}`
  end

  describe 'container' do
    it 'builds the Docker image successfully' do
      result = system("docker inspect #{image_name} > /dev/null 2>&1")
      expect(result).to be true
    end

    it 'starts the entrypoint and attempts GitHub API call' do
      output = run_action(fixture: 'pull_request_minor.json')
      expect(output).to include('Octokit')
    end

    it 'fails with bad credentials when using a fake token' do
      output = run_action(fixture: 'pull_request_minor.json')
      expect(output).to include('Bad credentials')
    end

    it 'rejects empty repository identifier' do
      output = run_action(fixture: 'pull_request_minor.json', env: { 'GITHUB_REPOSITORY' => '' })
      expect(output).to include('invalid as a repository identifier')
    end
  end

  describe 'release creation' do
    let(:mock_api) { MockGitHubAPI.new }
    let(:workspace) { Dir.mktmpdir('verselicious-test') }

    before do
      system("git init #{workspace}", out: File::NULL, err: File::NULL)
      system("git -C #{workspace} commit --allow-empty -m 'init'", out: File::NULL, err: File::NULL)
      mock_api.start
    end

    after do
      mock_api.stop
      FileUtils.remove_entry(workspace)
    end

    it 'creates a minor release with correct tag' do
      mock_api.labels = ['minor']
      output = run_action(
        fixture: 'pull_request_minor.json',
        workspace: workspace,
        env: { 'GITHUB_API_URL' => "http://host.docker.internal:#{mock_api.port}" }
      )

      expect(output).to include('Bumping minor: 0.0.0 -> 0.1.0')
      expect(output).to include('Release created:')
      expect(mock_api.release_requests.size).to eq(1)
      expect(mock_api.release_requests.first['tag_name']).to eq('v0.1.0')
    end

    it 'creates a major release with correct tag' do
      mock_api.labels = ['major']
      output = run_action(
        fixture: 'pull_request_major.json',
        workspace: workspace,
        env: { 'GITHUB_API_URL' => "http://host.docker.internal:#{mock_api.port}" }
      )

      expect(output).to include('Bumping major: 0.0.0 -> 1.0.0')
      expect(mock_api.release_requests.size).to eq(1)
      expect(mock_api.release_requests.first['tag_name']).to eq('v1.0.0')
    end

    it 'creates a patch release with correct tag' do
      mock_api.labels = ['patch']
      output = run_action(
        fixture: 'pull_request_patch.json',
        workspace: workspace,
        env: { 'GITHUB_API_URL' => "http://host.docker.internal:#{mock_api.port}" }
      )

      expect(output).to include('Bumping patch: 0.0.0 -> 0.0.1')
      expect(mock_api.release_requests.size).to eq(1)
      expect(mock_api.release_requests.first['tag_name']).to eq('v0.0.1')
    end

    it 'skips release when no version label is present' do
      mock_api.labels = []
      output = run_action(
        fixture: 'pull_request_no_label.json',
        workspace: workspace,
        env: { 'GITHUB_API_URL' => "http://host.docker.internal:#{mock_api.port}" }
      )

      expect(output).to include('No version bump label found. Skipping.')
      expect(mock_api.release_requests).to be_empty
    end
  end
end
