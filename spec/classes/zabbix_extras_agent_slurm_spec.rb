require 'spec_helper'

describe 'zabbix_extras::agent::slurm' do
  include_context :defaults

  let(:facts){ default_facts }

  it { should create_class('zabbix_extras::agent::slurm') }
  it { should contain_class('zabbix::agent') }

  it { should contain_zabbix__agent__userparameter('slurm').with_ensure('present') }

  it "should create UserParameter for slurm" do
    verify_user_parameter_contents(catalogue, 'slurm', [
      'UserParameter=slurmd.state[*],NODE=$1 ; sinfo -n ${NODE:-$(hostname -s)} --noheader -o "%T"',
    ])
  end

  context 'when ensure => absent' do
    let(:params) {{ :ensure => 'absent' }}
    it { should contain_zabbix__agent__userparameter('slurm').with_ensure('absent') }
  end

  context "with ensure => 'foo'" do
    let(:params) {{ :ensure => 'foo' }}
    it "should raise an error" do
      expect { should compile }.to raise_error(/does not match/)
    end
  end
end
