output id {
    value = aws_efs_file_system.efs_storage.id
}
output rds_endpoint {
    value = aws_rds_cluster.mod.endpoint
}
output s3_website_domain {
    value = aws_s3_bucket.static_content.website_domain
}