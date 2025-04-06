function get_aws_public_ip(tag, timestamp, record)
    local handle = io.popen("curl -s http://169.254.169.254/latest/meta-data/public-ipv4")
    local public_ip = handle:read("*a")
    handle:close()
    
    record["public_ip"] = public_ip:gsub("%s+", "")  -- remove any whitespace
    return 1, timestamp, record
end
