When(/^I run the health check script$/) do
  @output = `./bin/health-check.rb`
  @result = $?
end

When(/^I run the health check script with env ([^"]*)$/) do |vars|
  f = Tempfile.open('command.sh')
  file_contents = <<EOS
#!/bin/bash -e
#{vars} ./bin/health-check.rb 2>&1
EOS
  f.write(file_contents)
  f.close

  `chmod +x #{f.path}`

  @output = `bash #{f.path}`
  @result = $?

  f.unlink
end

Then(/^the exit status should be (\d+)$/) do |status|
  expect(@result.exitstatus).to eq(status.to_i)
end

Then(/^the output includes '([^"]*)'$/) do |msg|
  expect(@output).to include(msg)
end
