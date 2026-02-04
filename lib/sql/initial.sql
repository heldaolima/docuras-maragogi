-- Arquivos (imagens, PDFs, etc.)
CREATE TABLE files (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  path TEXT NOT NULL
);

-- Empresa (singleton)
CREATE TABLE company (
  id INTEGER PRIMARY KEY CHECK (id = 1),
  company_name TEXT,
  brand_name TEXT NOT NULL,
  cnpj TEXT,
  address TEXT,
  phone_number_1 TEXT,
  phone_number_2 TEXT,
  logo_image_id INTEGER,
  pix_key TEXT,
  deposit_agency TEXT,
  deposit_account TEXT,
  FOREIGN KEY (logo_image_id) REFERENCES files(id)
);

-- Biscoitos
CREATE TABLE product (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  unit_retail_price INTEGER NOT NULL,
  unit_wholesale_price INTEGER NOT NULL
);

-- Caixas de produtos
CREATE TABLE product_box (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  product_id INTEGER NOT NULL,
  price INTEGER NOT NULL,
  units_per_box INTEGER NOT NULL,
  FOREIGN KEY (product_id) REFERENCES product(id)
);

-- Clientes
CREATE TABLE client (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  contact TEXT
);

-- Pedidos
CREATE TABLE orders (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  client_id INTEGER NOT NULL,
  number_per_client INTEGER NOT NULL,
  order_date INTEGER NOT NULL,
  FOREIGN KEY (client_id) REFERENCES client(id)
);

-- Produtos do pedido
CREATE TABLE order_product (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  order_id INTEGER NOT NULL,
  product_box_id INTEGER NOT NULL,
  quantity INTEGER NOT NULL,
  price INTEGER NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(id),
  FOREIGN KEY (product_box_id) REFERENCES product_box(id)
);