require 'spec_helper'

describe 'hive::server2::config', :type => 'class' do
  $test_os.each do |facts|
    os = facts['operatingsystem']
    path = $test_config_dir[os]

    context "on #{os}" do
      let(:facts) do
        facts
      end
      it { should compile.with_all_deps }
      it { should contain_file(path + '/hive-site.xml') }
    end
  end
end

describe 'hive::server2', :type => 'class' do
  $test_os.each do |facts|
    os = facts['operatingsystem']

    context "on #{os}" do
      let(:facts) do
        facts
      end
      it { should compile.with_all_deps }
      it { should contain_class('hive::server2::install') }
      it { should contain_class('hive::server2::config') }
      it { should contain_class('hive::server2::service') }
    end
  end
end
