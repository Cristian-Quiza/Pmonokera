# Setup local development environment

echo "Installing dependencies for customer-service..."
cd customer-service
bundle install
rails db:create db:migrate db:seed
echo "✓ Customer service ready"

echo "Installing dependencies for order-service..."
cd ../order-service
bundle install
rails db:create db:migrate db:seed
echo "✓ Order service ready"

echo "Setup complete! Run:"
echo "  - Customer service: cd customer-service && rails s -p 3001"
echo "  - Order service: cd order-service && rails s -p 3000"
echo "  - Frontend: cd frontend && npm run dev"
