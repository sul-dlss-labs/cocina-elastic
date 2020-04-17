# cocina-elastic

A proof-of-concept for persisting Cocina models in ElasticSearch.

## Setup
### Start ElasticSearch cluster
```
docker-compose up -d
```

### Install dependencies
```
bundler install
```

### Generate some random DROs
This will generate 10 files in `data/`, each which contains 25 DROs.
```
exe/data generate 10
```

To see the ElasticSearch operations, append `--log` to any of these commands.

### Create the index
```
exe/index create
```

### Index the DROs
```
exe/bulk bulk_files 10
```

## Sample queries
### List some druids
```
curl -X GET "localhost:9200/dro/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": { "match_all": {} },
  "_source": false
}
'
```

### Retrieve a single DRO
```
curl "localhost:9200/dro/_doc/druid:ym567jf9155?pretty"

Search by label
curl -X GET "localhost:9200/dro/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match": {
        "label": "fugiat"
    }
  }
}
'
```

### Search by sourceId
```
curl -X GET "localhost:9200/dro/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "term": {
        "identification.sourceId": "sul:distinctio_dolorem_assumenda_mollitia_ex_qui_non_voluptatibus_minus_dolore_architecto_et_ratione"
    }
  }
}
'
```

### Search by catalogLink
```
curl -X GET "localhost:9200/dro/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "nested": {
        "path": "identification.catalogLinks",
        "query": {
            "bool": {
                "must": [
                    { "match": { "identification.catalogLinks.catalog": "symphony" }},
                    { "match": { "identification.catalogLinks.catalogRecordId": "17041099" }}
                ]
            }
        }
    }
  }
}
'
```
