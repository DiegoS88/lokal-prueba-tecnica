# Datos iniciales para probar la aplicacion rapidamente.
# Idempotente: se puede ejecutar cuantas veces se quiera.
# Uso: bin/rails db:seed

store = Store.find_or_create_by!(name: "Tienda Demo")

providers = {
  "Distribuidora Alfa" => [
    { name: "Café Grano 1kg", price_cents: 12_500, stock: 20 },
    { name: "Azúcar Refinada 5kg", price_cents: 8_900, stock: 35 },
    { name: "Aceite Girasol 1L", price_cents: 4_700, stock: 10 }
  ],
  "Importadora Beta" => [
    { name: "Arroz Largo 10kg", price_cents: 15_000, stock: 12 },
    { name: "Harina de Trigo 25kg", price_cents: 22_400, stock: 3 },
    { name: "Lentejas Bolsa 5kg", price_cents: 6_800, stock: 18 }
  ]
}

providers.each do |provider_name, products|
  provider = Provider.find_or_create_by!(name: provider_name)
  products.each do |attrs|
    product = provider.products.find_or_initialize_by(name: attrs[:name])
    product.update!(price_cents: attrs[:price_cents], stock: attrs[:stock])
  end
end

puts "Seed listo:"
puts "  Tienda: #{store.name}"
Provider.find_each do |provider|
  puts "  Proveedor #{provider.name}: #{provider.products.count} productos"
end
