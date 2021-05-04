require 'net/http'
require 'json'
require 'faraday'

url = 'http://localhost:3000/api/v1/charge_queries/expiration_date'
response = Faraday.get(url, {query: '2021-05-02', pm_query: 'Boleto'})

puts response.body


#/api/v1/charge_queries/expiration_date?pm_query=Boleto&query=2021-05-02



