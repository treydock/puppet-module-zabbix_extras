#!/usr/bin/env ruby

require 'rubygems'
require 'json'
require 'facter'

fact_value = Facter[:blockdevices].value
devices = fact_value.split(',')

data = devices.collect do |device|
  {
    "{#BLOCK_DEVICE}" => File.join('/dev', device),
  }
end

block_devices = {}
block_devices[:data] = data

zabbix_data = JSON.parse(block_devices.to_json)

jj zabbix_data
