# Testing OpenSearch Search via Dashboards

## Method 1: Using Dev Tools Console (Recommended)

1. **Open Dev Tools in Dashboards:**
   - In OpenSearch Dashboards, click on the hamburger menu (☰) in the top left
   - Navigate to **Management** → **Dev Tools** (or use the shortcut: click the wrench icon)

2. **Create an Index with Sample Data:**
   ```json
   PUT /books/_doc/1
   {
     "title": "The Great Gatsby",
     "author": "F. Scott Fitzgerald",
     "year": 1925,
     "genre": "Fiction"
   }

   PUT /books/_doc/2
   {
     "title": "To Kill a Mockingbird",
     "author": "Harper Lee",
     "year": 1960,
     "genre": "Fiction"
   }

   PUT /books/_doc/3
   {
     "title": "1984",
     "author": "George Orwell",
     "year": 1949,
     "genre": "Dystopian Fiction"
   }

   PUT /books/_doc/4
   {
     "title": "Pride and Prejudice",
     "author": "Jane Austen",
     "year": 1813,
     "genre": "Romance"
   }
   ```

3. **Search for Documents:**
   ```json
   # Simple search - find all books
   GET /books/_search

   # Search for a specific term
   GET /books/_search
   {
     "query": {
       "match": {
         "title": "Great"
       }
     }
   }

   # Search by author
   GET /books/_search
   {
     "query": {
       "match": {
         "author": "Fitzgerald"
       }
     }
   }

   # Full-text search across multiple fields
   GET /books/_search
   {
     "query": {
       "multi_match": {
         "query": "fiction",
         "fields": ["title", "genre"]
       }
     }
   }

   # Search with filters
   GET /books/_search
   {
     "query": {
       "bool": {
         "must": [
           {
             "match": {
               "genre": "Fiction"
             }
           }
         ],
         "filter": [
           {
             "range": {
               "year": {
                 "gte": 1900
               }
             }
           }
         ]
       }
     }
   }
   ```

## Method 2: Using Discover (Visual Interface)

1. **Create Index Pattern:**
   - Go to **Management** → **Index Patterns**
   - Click **Create index pattern**
   - Enter `books*` as the pattern
   - Click **Next step**
   - Select `@timestamp` as the time field (or choose "I don't want to use the Time Filter")
   - Click **Create index pattern**

2. **View Data in Discover:**
   - Go to **Discover** from the left menu
   - Select the `books*` index pattern
   - You should see your documents

3. **Search in Discover:**
   - Use the search bar at the top to search
   - Try: `author:"Fitzgerald"` or `title:Great`
   - Use filters on the left sidebar

## Method 3: Using Search Application (OpenSearch 2.11+)

1. **Create a Search Application:**
   - Go to **Search** → **Applications**
   - Click **Create application**
   - Name it "Book Search"
   - Select the `books` index
   - Configure search settings
   - Save and test

## Quick Test Commands

Run these in Dev Tools to quickly test:

```json
# 1. Create index with mapping
PUT /books
{
  "mappings": {
    "properties": {
      "title": { "type": "text" },
      "author": { "type": "text" },
      "year": { "type": "integer" },
      "genre": { "type": "keyword" }
    }
  }
}

# 2. Bulk insert data
POST /books/_bulk
{"index":{}}
{"title":"The Great Gatsby","author":"F. Scott Fitzgerald","year":1925,"genre":"Fiction"}
{"index":{}}
{"title":"To Kill a Mockingbird","author":"Harper Lee","year":1960,"genre":"Fiction"}
{"index":{}}
{"title":"1984","author":"George Orwell","year":1949,"genre":"Dystopian Fiction"}

# 3. Simple search
GET /books/_search?q=Gatsby

# 4. Advanced search
GET /books/_search
{
  "query": {
    "match_all": {}
  },
  "sort": [
    { "year": "desc" }
  ]
}
```

## Verify Search is Working

After running the search queries, you should see:
- Results with document counts
- Highlighted search terms
- Relevance scores
- Full document data

