require 'net/http'
require 'json'
require 'faraday'

uri = URI('http://localhost:3000/api/v1/invoices.json')
response = Faraday.get(uri)

boleto = []
pix = []
credito = []

def statuscode(method)
  case method
    when "pending"
      return "01"
    when "paid"
      return "05"
    when "refused-miss"
      return "09"
    when "refused-wrong"
      return "10"
    else
      return "11"
  end
end

r = JSON.parse(response.body, symbolize_names: true)
r.each do |x|
  boleto << x if x[:company_payment_method] == "Boleto"
  pix << x if x[:company_payment_method] == 'Pix'
  credito << x if x[:company_payment_method] == 'Cartao Credito'
end

#somar valor total de cada meio de pagamento
boletosum = boleto.map {|s| s[:pprice]}
pixsum = pix.map {|s| s[:pprice]}
creditosum = credito.map {|s| s[:pprice]}

#imprimir token de cobranças de cartao de credito + data de venc
c = credito.map do |credito|
  credito[:token] + credito[:due_date].gsub(/[-]/, '') + format('%010d', credito[:pprice]*100) + statuscode(credito[:status])
end

#imprimir token de cobranças de pix + data de venc
p = pix.map do |pix|
  pix[:token] + pix[:due_date].gsub(/[-]/, '') + format('%010d', pix[:pprice]*100) + statuscode(pix[:status])
end

#imprimir token de cobranças de boleto + data de venc
b = boleto.map do |boleto|
  boleto[:token] + boleto[:due_date].gsub(/[-]/, '') + format('%010d', boleto[:pprice]*100) + statuscode(boleto[:status])
end

#gerar timestamp
t = Time.now.strftime("%Y%m%d")

# criar arquivo txt cobrança
File.open("#{t}_CARTAO_DE_CREDITO_EMISSAO.txt", "w+") do |f|
	f.puts "H#{format('%05d', credito.count)}"
  c.each { |element| f.puts"B#{(element)}" }
      f.puts "F#{format('%015d', creditosum.sum*100)}"
end

File.open("#{t}_PIX_EMISSAO.txt", "w+") do |f|
	f.puts "H#{format('%05d', pix.count)}"
  p.each { |element| f.puts"B#{(element)}" }
      f.puts "F#{format('%015d', pixsum.sum*100)}"
end

File.open("#{t}_BOLETO_EMISSAO.txt", "w+") do |f|
	f.puts "H#{format('%05d', boleto.count)}"
  b.each { |element| f.puts"B#{(element)}" }
    f.puts "F#{format('%015d', boletosum.sum*100)}"
end







