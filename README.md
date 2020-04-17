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

## Re-indexing (to changes index mappings or source documents)
Note: In testing these locally, I encountered memory issues. If testing locally, use a small number of documents.

Re-indexing can be performed using [update-by-query](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-update-by-query.html#picking-up-a-new-property) (to update in place) or [reindex](https://www.elastic.co/guide/en/elasticsearch/reference/7.6/docs-reindex.html) (to reindex into a new index).

### Update-by-query
In this example, the `type` field will be indexed.

#### Change the index
```
curl -X PUT "localhost:9200/dro/_mapping?pretty" -H 'Content-Type: application/json' -d'
{
  "properties": {
    "type": {
        "type": "keyword"
    }
  }
}
'
```

#### Update-by-query
```
curl -X POST "localhost:9200/dro/_update_by_query?refresh&conflicts=proceed&pretty"
```

#### Test
```
curl -X POST "localhost:9200/dro/_search?filter_path=hits.total&pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match": {
      "type": "http://cocina.sul.stanford.edu/models/image.jsonld"
    }
  }
}
'
```

### Reindex
In this example, `externalIdentifier` will be renamed to `druid` in the source documents.

#### Create the new index
```
exe/index create --index=dro2
```

#### Re-index
```
curl -X POST "localhost:9200/_reindex?pretty&wait_for_completion=false" -H 'Content-Type: application/json' -d'
{
  "source": {
    "index": "dro"
  },
  "dest": {
    "index": "dro2"
  },
  "script": {
    "lang": "painless",
    "source": "ctx._source.druid = ctx._source.externalIdentifier;\nctx._source.remove(\"externalIdentifier\");"
  }  
}
'
```
