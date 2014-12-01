require 'spec_helper'

describe 'zabbix_extras::agent::mysql' do
  let :facts do
    {
      :osfamily                   => 'RedHat',
      :operatingsystemmajrelease  => '6',
    }
  end

  let(:pre_condition) {
    [
      "class { 'mysql::server': }",
      "class { 'mysql::server::monitor':
        mysql_monitor_username => 'zabbix-agent',
        mysql_monitor_password => 'foo',
        mysql_monitor_hostname => 'localhost',
      }",
    ]
  }

  it { should create_class('zabbix_extras::agent::mysql') }
  it { should contain_class('mysql::server::monitor') }
  it { should contain_class('zabbix::agent') }

  it { should contain_zabbix__agent__userparameter('mysql').with_ensure('present') }

  it "should create UserParameter for mysql" do
    content = catalogue.resource('zabbix::agent::userparameter', 'mysql').send(:parameters)[:content]
    content.split("\n").reject { |c| c =~ /(^#|^$)/ }.should == [
      'UserParameter=mysql.status[*],echo "show global status where Variable_name=\'$1\';" | HOME=/var/lib/zabbix mysql -N | awk \'{print $$2}\'',
      'UserParameter=mysql.slave.status[*],echo "SHOW SLAVE STATUS \G" | HOME=/var/lib/zabbix mysql | grep $1 | awk \'{print $$2}\'',
      'UserParameter=mysql.size[*],echo "select sum($(case "$3" in both|"") echo "data_length+index_length";; data|index) echo "$3_length";; free) echo "data_free";; esac)) from information_schema.tables$([[ "$1" = "all" || ! "$1" ]] || echo " where table_schema=\'$1\'")$([[ "$2" = "all" || ! "$2" ]] || echo "and table_name=\'$2\'");" | HOME=/var/lib/zabbix mysql -N',
      'UserParameter=mysql.ping,HOME=/var/lib/zabbix mysqladmin ping | grep -c alive',
      'UserParameter=mysql.version,mysql -V',
    ]
  end

  it do
    should contain_file('/var/lib/zabbix/.my.cnf').with({
      :ensure   => 'present',
      :path     => '/var/lib/zabbix/.my.cnf',
      :owner    => 'zabbix',
      :group    => 'zabbix',
      :mode     => '0400',
      :before   => 'Zabbix::Agent::Userparameter[mysql]',
    })
  end

  it "should set my.cnf values" do
    verify_contents(catalogue, '/var/lib/zabbix/.my.cnf', [
      '[client]',
      'user=zabbix-agent',
      'host=localhost',
      'password=\'foo\'',
    ])
  end

  context 'when ensure => absent' do
    let(:pre_condition) {}
    let(:params) {{ :ensure => 'absent' }}
    it { should_not contain_class('mysql::server::monitor') }
    it { should contain_zabbix__agent__userparameter('mysql').with_ensure('absent') }
    it { should contain_file('/var/lib/zabbix/.my.cnf').with_ensure('absent') }
  end

  context "with include_mysql => false" do
    let(:pre_condition) {}
    let(:params) {{ :include_mysql => false }}
    it { should_not contain_class('mysql::server::monitor') }
  end

  context "with ensure => 'foo'" do
    let(:params) {{ :ensure => 'foo' }}
    it "should raise an error" do
      expect { should compile }.to raise_error(/does not match/)
    end
  end

  context "with include_mysql => 'foo'" do
    let(:params) {{ :include_mysql => 'foo' }}
    it "should raise an error" do
      expect { should compile }.to raise_error(/is not a boolean/)
    end
  end
end
