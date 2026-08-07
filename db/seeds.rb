# Datos iniciales para probar la aplicacion rapidamente.
# Idempotente: se puede ejecutar cuantas veces se quiera.
# Uso: bin/rails db:seed

store = Store.find_or_create_by!(name: "Tienda Demo")

currency = Currency.find_or_initialize_by(code: "CLP")
currency.update!(precision: 3, name: "Peso Chileno")

providers = {
  "Distribuidora Alfa" => [
    { name: "Café Grano 1kg", price: 12_500, stock: 20 },
    { name: "Azúcar Refinada 5kg", price: 8_900, stock: 35 },
    { name: "Aceite Girasol 1L", price: 4_700, stock: 10 }
  ],
  "Importadora Beta" => [
    { name: "Arroz Largo 10kg", price: 15_000, stock: 12 },
    { name: "Harina de Trigo 25kg", price: 22_400, stock: 3 },
    { name: "Lentejas Bolsa 5kg", price: 6_800, stock: 18 }
  ]
}

providers.each do |provider_name, products|
  provider = Provider.find_or_create_by!(name: provider_name)
  products.each do |attrs|
    product = provider.products.find_or_initialize_by(name: attrs[:name])
    product.update!(price: attrs[:price], stock: attrs[:stock])
  end
end

puts "Seed listo:"
puts "  Tienda: #{store.name}"
Provider.find_each do |provider|
  puts "  Proveedor #{provider.name}: #{provider.products.count} productos"
end
