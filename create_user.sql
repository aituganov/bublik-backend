DO $$
BEGIN
	IF NOT EXISTS (SELECT * FROM pg_roles WHERE  rolname = 'bublik_admin') THEN
		CREATE ROLE bublik_admin WITH SUPERUSER LOGIN CREATEDB PASSWORD 'Br0adway';
	END IF;
END
$$