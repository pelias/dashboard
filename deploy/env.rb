#!/usr/bin/env ruby

environment = ARGV[0]
ARGV[0] = nil

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../DeployGemfile', __FILE__)
load Gem.bin_path('bundler', 'bundle')

require 'aws-sdk'

# AWS.config(
#   access_key_id: ENV["#{environment.upcase}_AWS_ACCESS_KEY_ID"],
#   secret_access_key: ENV["#{environment.upcase}_AWS_SECRET_ACCESS_KEY"]
# )
AWS.config(
  access_key_id: ENV['AWS_ACCESS_KEY_ID'],
  secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
)

config = {
  staging: {
    stack_id: 'df8fcfa4-b4de-405c-b27b-b4d33508998d',
    layer_id: 'f15f5d55-4fe0-4ae0-80df-e34321b87f54',
    app_id: '020408de-90ab-4671-80a1-89c3549143b0'
  },
  development: {
    stack_id: '521dad25-f6b8-4f1f-97bc-7684b96c744b',
    layer_id: 'cf95d61a-ea84-4272-a072-982157d3ba60',
    app_id: 'a648211e-7b74-4db3-b49e-7b36587436c2'
  }
}

client = AWS::OpsWorks::Client.new

nodes = client.describe_instances(
  stack_id: config[environment.to_sym][:stack_id],
  layer_id: config[environment.to_sym][:layer_id]
)
instance_array = []
nodes[:instances].each { |instance| instance_array << instance.values_at(:instance_id) }

deployment = client.create_deployment(
  stack_id: config[environment.to_sym][:stack_id],
  app_id: config[environment.to_sym][:app_id],
  instance_ids: instance_array,
  command: {
    name: 'deploy'
  },
  comment: "Deploying build from circleci: #{ENV['CIRCLE_BUILD_NUM']} sha: #{ENV['CIRCLE_SHA1']} #{ENV['CIRCLE_COMPARE_URL']}"
)

timeout = 60 * 5
time_start = Time.now.utc
success = false

process = ['\\', '|', '/', '-']
i = 0
until success
  desc = client.describe_deployments(deployment_ids: [deployment[:deployment_id]])
  success = desc[:deployments][0][:status] == 'successful'
  time_passed = Time.now.utc - time_start
  if i >= process.length - 1
    i = 0
  else
    i += 1
  end
  print "\r"
  print "Deploying: #{process[i]} status: #{desc[:deployments][0][:status]} timeout: #{timeout} -- time passed: #{time_passed}"
  exit 1 if timeout < time_passed
  sleep 4
end

exit 0
