"use strict"

port = process.env.DOTCLOUD_CACHE_REDIS_PORT or 6379
host = process.env.DOTCLOUD_CACHE_REDIS_HOST or 'localhost'
pass = process.env.DOTCLOUD_CACHE_REDIS_PASSWORD or null

module.exports = redisClient port, host, auth_pass: pass

