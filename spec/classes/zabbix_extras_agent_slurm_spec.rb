require 'spec_helper'

describe 'zabbix_extras::agent::slurm' do
  let :facts do
    {
      :osfamily                   => 'RedHat',
      :operatingsystemmajrelease  => '6',
    }
  end

  it { should create_class('zabbix_extras::agent::slurm') }
  it { should contain_class('zabbix::agent') }

  it { should contain_zabbix__agent__userparameter('slurm').with_ensure('present') }

  it "should create UserParameter for slurm" do
    verify_user_parameter_contents(catalogue, 'slurm', [
      'UserParameter=slurm.sinfo[*],NODE=$1 ; FIELD=$2 ; sinfo -n ${NODE:-$(hostname -s)} --noheader -o "${FIELD:-%T}"',
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
