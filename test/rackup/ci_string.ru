# frozen_string_literal: true

# Generates a response with single string bodies, size set via ENV['CI_BODY_CONF'] or
# `Body-Conf` request header.
# See 'CI - test/rackup/ci-*.ru files' or docs/test_rackup_ci_files.md

require 'securerandom'

env_len = (t = ENV['CI_BODY_CONF']) ? t[/\d+\z/].to_i : 10

headers = {}
headers['Content-Type'] = 'text/plain; charset=utf-8'
25.times { |i| headers["X-My-Header-#{i}"] = SecureRandom.hex(25) }

hdr_dly = 'HTTP_DLY'
hdr_body_conf = 'HTTP_BODY_CONF'
hdr_content_length = 'Content-Length'

# length = 1018  bytesize = 1024
str_1kb = "──#{SecureRandom.hex 507}─\n".freeze

env_len = (t = ENV['CI_BODY_CONF']) ? t[/\d+\z/].to_i : 10

run lambda { |env|
  info = if (dly = env[hdr_dly])
    sleep dly.to_f
    "#{Process.pid}\nHello World\nSlept #{dly}\n".dup
  else
    "#{Process.pid}\nHello World\n".dup
  end
  info_len_adj = 1023 - info.bytesize

  len = (t = env[hdr_body_conf]) ? t[/\d+\z/].to_i : env_len

  info << str_1kb.byteslice(0, info_len_adj) << "\n" << (str_1kb * (len-1))
  headers[hdr_content_length] = (1_024 * len).to_s
  [200, headers, [info]]
}
