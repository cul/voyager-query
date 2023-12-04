# voyager-query

A simple web API to perform Voyager queries via HTTP requests, useful as a workaround for ARM-based MACs.

## Requirements

- Ruby 3.2.2
- Intel-based architecture (on host machine)

## First-Time Setup (for developers)
Install [rbenv](https://github.com/rbenv/rbenv)
````
brew install rbenv ruby-build
rbenv init
echo 'eval "$(rbenv init - zsh)"' >> ~/.zshrc
````
Clone the new forked repo onto your dev machine.
````
git clone git@github.com:cul/voyager-query.git
````
Install gem dependencies.
```
cd voyager-query
bundler install
```
Set up config file.
  - Create `config/voayger.yml` from template.
  ```
  cp config/templates/voyager.template.yml config/voyager.yml
  ```
  - Replace in placeholder values inside `config/voyager.yml`.
    - Replace the following fields with Voyager's Oracle database parameters: `database_name` `user` `password`
  - Set `remote_request_api_key` to a secure key to be added to the header of HTTP requests.

Run the server.
  ```
  rails s -p 3000
  ```
And in a separate terminal window, establish an SSH tunnel connection to the voyager db on port 1527:
  ```
  ssh yourusername@connect.cul.columbia.edu -L 1527:voyager-db.cul.columbia.edu:1527 -N
  ```
## Accessing API Endpoints
Note: all HTTP requst headers must contain the authorization key set in `config/voyager.yml` or they will be rejected.
To include your key in a `curl` request, run
  ```
  curl -H "Authorization: Token the_token_set_in_voyager_yml" http://localhost:3000/api/v1/records/12345678
  ```
### Endpoints:
`GET /api/v1/records/:bib_id`
- JSON response with information about this record:
  ```
  {
    "bib_id": 1234567,
    "holdings_record_ids": [567890, 567891, 567892]
  }
  ```
`GET /api/v1/records/:bib_id/record.marc`
- MARC binary response with bib record MARC

`GET /api/v1/records/:bib_id/holdings/:holdings_record_id/record.marc`
- Returns the holdings record MARC
        
## Testing
To run the test suite locally on your machine (mocking db backend functionality) run:
```
bundle exec rspec
```
To test the Oracle db connection run:
```
bundle exec rake voyager_query:test:check_oracle_connection
```

## Deployment
We use Capistrano for deployment. To deploy to our temporary dev instance run:
```
cap voyager_query_dev deploy
```
