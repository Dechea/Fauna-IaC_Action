#!/bin/bash

db_domain="db.fauna.com"
graphql_domain="graphql.fauna.com"

case "${1,,}" in
  "eu")
    db_domain="db.eu.fauna.com"
    graphql_domain="graphql.eu.fauna.com"
    ;;
  "us")
    db_domain="db.us.fauna.com"
    graphql_domain="graphql.us.fauna.com"
    ;;
  "preview")
    db_domain="db.fauna-preview.com"
    graphql_domain="graphql.fauna-preview.com"
    ;;
esac

echo "$db_domain:$graphql_domain"