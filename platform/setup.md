
## gcloud scripts
# enable app engine admin
```
gcloud app create --region=$APP_ENGINE_REGION

```

# - give cloud build service account deploy permission to app engine
https://cloud.google.com/cloud-build/docs/securing-builds/set-service-account-permissions

# - enable app engine
# - enable sql


# # terraform stuff
# - create postgres instance
# - create vm instance
# - ansible that bitch up
# - create build pipeline hooked to proper branch (dev-ccrm to dev, [feature]-ccrm to [feature], etc)buckfactor@infinite-tacos:~/work/soro/ccrm (dev)$



<!-- 
gcloud iam service-accounts create sa-$PROJECT_ID
gcloud iam service-accounts list

gcloud iam service-accounts add-iam-policy-binding sa-$PROJECT_ID@$PROJECT_ID.iam.gserviceaccount.com \
  --member='serviceAccount:sa-$PROJECT_ID@$PROJECT_ID.iam.gserviceaccount.com' \
  --role='roles/cloudsql.admin'

gcloud iam service-accounts add-iam-policy-binding sa-PROJECT-ID@PROJECT-ID.iam.gserviceaccount.com \
  --member='serviceAccount:sa-PROJECT-ID@PROJECT-ID.iam.gserviceaccount.com' \
  --role='roles/cloudsql.admin' -->