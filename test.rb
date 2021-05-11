require 'net/http'
require 'json'
require 'faraday'

uri = URI('http://localhost:3000/api/v1/invoices.json')
response = Faraday.get(uri)

boleto = []
pix = []
credito = []

r = JSON.parse(response.body, symbolize_names: true)
r[:charges][:all].each do |x|
boleto << x if x[:payment_method] == "Boleto"
pix << x if x[:payment_method] == 'Pix'
credito << x if x[:payment_method] == 'Cartao Credito'
end

puts "Sucesso!"

#imprimir cobranças de cartao de credito
c = credito.map do |ptoken|
ptoken[:product_token]
end

#imprimir cobranças de pix
p = pix.map do |ptoken|
  ptoken[:product_token]
end

#imprimir cobranças de boleto
b = boleto.map do |ptoken|
  ptoken[:product_token]
end

#gerar timestamp
t = Time.now.strftime("%Y%m%d")

# criar arquivo txt cobrança - cartao de credito
File.open("#{t}_CARTAO_DE_CREDITO_EMISSAO.txt", "w+") do |f|
	f.puts "H#{format('%05d', credito.count)}"
  c.each { |element| f.puts"B#{(element)}" }
end

File.open("#{t}_PIX_EMISSAO.txt", "w+") do |f|
	f.puts "H#{format('%05d', pix.count)}"
  p.each { |element| f.puts"B#{(element)}" }
end

File.open("#{t}_BOLETO_EMISSAO.txt", "w+") do |f|
	f.puts "H#{format('%05d', boleto.count)}"
  b.each { |element| f.puts"B#{(element)}" }
end

