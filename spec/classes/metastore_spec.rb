require 'spec_helper'

describe 'hive::metastore::config', :type => 'class' do
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

describe 'hive::metastore', :type => 'class' do
  $test_os.each do |facts|
    os = facts['operatingsystem']

    context "on #{os}" do
      let(:facts) do
        facts
      end
      it { should compile.with_all_deps }
      it { should contain_class('hive::metastore::install') }
      it { should contain_class('hive::metastore::config') }
      it { should contain_class('hive::metastore::service') }
    end
  end
end
