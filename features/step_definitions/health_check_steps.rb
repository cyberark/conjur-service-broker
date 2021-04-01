# frozen_string_literal: true

When(/^I run the( buildpack)? health check script$/) do |buildpack|
  @output = if !(buildpack.nil? || buildpack.empty?)
              `./bin/buildpack-health-check`
            else
              `./bin/health-check.rb`
            end

  @result = $?
end

When(/^I run the( buildpack)? health check script with env ([^"]*)$/) do |buildpack, vars|
  f = Tempfile.open('command.sh')

  command = if !(buildpack.nil? || buildpack.empty?)
              './bin/buildpack-health-check'
            else
              './bin/health-check.rb'
            end

  file_contents = <<~SCRIPT
    #!/bin/bash -e
    #{vars} #{command} 2>&1
  SCRIPT

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
