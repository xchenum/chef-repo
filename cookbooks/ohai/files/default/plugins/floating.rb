#
# Cookbook Name:: ohai
# Plugin:: floating_plugin
#
# "THE BEER-WARE LICENSE" (Revision 42):
# <john@dewey.ws> wrote this file. As long as you retain this notice you
# can do whatever you want with this stuff. If we meet some day, and you think
# this stuff is worth it, you can buy me a beer in return John-B Dewey Jr.
#

METADATA_ADDR = "169.254.169.254"
METADATA_URL = "/2008-02-01/meta-data"

provides "openstack"

begin
  cmd = "curl http://#{METADATA_ADDR}#{METADATA_URL}/public-ipv4"
  status, stdout, stderr = run_command(:command => cmd)

  openstack Mash.new
  openstack[:public_ipv4] = (stdout.nil? ? "" : stdout)
rescue => e
  Chef::Log.warn "Ohai floating_plugin failed with: '#{e}'"
end
