def verify_exact_file_contents(subject, title, expected_lines)
  content = subject.resource('file', title).send(:parameters)[:content]
  content.split(/\n/).reject { |line| line =~ /(^$|^#)/ }.should == expected_lines
end

def verify_user_parameter_contents(subject, title, expected_lines)
  content = subject.resource('zabbix::agent::userparameter', title).send(:parameters)[:content]
  content.split(/\n/).reject { |line| line =~ /(^#|^$)/ }.should == expected_lines
end
