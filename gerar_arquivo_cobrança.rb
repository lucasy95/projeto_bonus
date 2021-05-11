require 'net/http'
require 'json'
require 'faraday'

uri = URI('http://localhost:3000/api/v1/invoices.json')
response = Faraday.get(uri)

boleto = []
pix = []
credito = []

r = JSON.parse(response.body, symbolize_names: true)
r.each do |x|
  boleto << x if x[:company_payment_method] == "Boleto"
  pix << x if x[:company_payment_method] == 'Pix'
  credito << x if x[:company_payment_method] == 'Cartao Credito'
end

#imprimir token de cobranças de cartao de credito + data de venc
c = credito.map do |credito|
  credito[:token] + credito[:due_date].gsub(/[-]/, '')
end

#imprimir token de cobranças de pix + data de venc
p = pix.map do |pix|
  pix[:token] + pix[:due_date].gsub(/[-]/, '')
end

#imprimir token de cobranças de boleto + data de venc
b = boleto.map do |boleto|
  boleto[:token] + boleto[:due_date].gsub(/[-]/, '')
end

#gerar timestamp
t = Time.now.strftime("%Y%m%d")

# criar arquivo txt cobrança
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


