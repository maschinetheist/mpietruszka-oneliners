# Show Cloud SQL user creation for built-in/basic auth users
resource.type="cloudsql_database"
protoPayload.authorizationInfo.permission="cloudsql.users.create"
NOT (protoPayload.request.body.type = "CLOUD_IAM_USER" OR protoPayload.request.body.type = "CLOUD_IAM_SERVICE_ACCOUNT")
protoPayload.request.@type = "type.googleapis.com/google.cloud.sql.v1beta4.SqlUsersInsertRequest"
