require_relative '../spec_helper'

describe 'cli: vars', type: :integration do
  with_reset_sandbox_before_each(config_server_enabled: true, user_authentication: 'uaa', uaa_encryption: 'asymmetric')

  let(:deployment_name) { manifest_hash['name'] }
  let(:director_name) { current_sandbox.director_name }
  let(:config_server_helper) { Bosh::Spec::ConfigServerHelper.new(current_sandbox, logger)}
  let(:manifest_hash) do
    Bosh::Spec::Deployments.test_release_manifest.merge(
      {
        'jobs' => [Bosh::Spec::Deployments.job_with_many_templates(
          name: 'our_instance_group',
          templates: [
            {'name' => 'job_with_property_types',
             'properties' => job_properties
            }
          ],
          instances: 1
        )]
      })
  end
  let(:cloud_config)  { Bosh::Spec::Deployments.simple_cloud_config }
  let(:client_env) { {'BOSH_CLIENT' => 'test', 'BOSH_CLIENT_SECRET' => 'secret', 'BOSH_CA_CERT' => "#{current_sandbox.certificate_path}"} }
  let(:job_properties) do
    {
      'gargamel' => {
        'secret_recipe' => 'poutine',
        'cert' => '((cert))'
      },
      'smurfs' => {
        'happiness_level' => '((happiness_level))',
        'phone_password' => '((/phone_password))'
      }
    }
  end

  def prepend_namespace(key)
    "/#{director_name}/#{deployment_name}/#{key}"
  end

  it 'should return list of config vars' do
    config_server_helper.put_value(prepend_namespace('happiness_level'), '10')

    deploy_from_scratch(no_login: true, manifest_hash: manifest_hash, cloud_config_hash: cloud_config, include_credentials: false, env: client_env)

    vars = table(bosh_runner.run('vars', json: true, include_credentials: false, deployment_name: deployment_name, env: client_env))

    vars_ids = vars.map { |obj|
      obj["ID"]
    }
    expect(vars_ids.length).to eq(3)

    vars_names = vars.map { |obj|
      obj["Name"]
    }
    expect(vars_names).to include("TestDirector/simple/cert")
    expect(vars_names).to include("TestDirector/simple/happiness_level")
    expect(vars_names).to include("phone_password")
  end
end
