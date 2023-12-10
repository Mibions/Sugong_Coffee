create database QuanLyCaPhe ON PRIMARY
(
	Name = DB_PRIMARY,
	Filename = N'D:\THHQTCSDL\QuanLyQuanCaPhe\DB_primary.mdf',
	Size = 3Mb,
	Maxsize = 10Mb,
	Filegrowth = 10%
),
(
	Name = DB_SECOND1_1,
	Filename = N'D:\THHQTCSDL\QuanLyQuanCaPhe\DB_second1_1.ndf',
	Size = 3Mb,
	Maxsize = 5Mb,
	Filegrowth = 10%
),
(
	Name = DB_SECOND1_2,
	Filename = N'D:\THHQTCSDL\QuanLyQuanCaPhe\DB_second1_2.ndf',
	Size = 3Mb,
	Maxsize = 5Mb,
	Filegrowth = 10%
),
(
	Name = DB_SECOND1_3,
	Filename = N'D:\THHQTCSDL\QuanLyQuanCaPhe\DB_second1_3.ndf',
	Size = 3Mb,
	Maxsize = 5Mb,
	Filegrowth = 5%
)
LOG ON
(
	Name = DB_Log,
	Filename = N'D:\THHQTCSDL\QuanLyQuanCaPhe\DB_Log.ldf',
	Size = 3Mb,
	Maxsize = 5Mb,
	Filegrowth = 5%
)
use QuanLyCaPhe


-----------------------------------------------------------CREATE TABLE---------------------------------------------------------------------
CREATE TABLE TAI_KHOAN
(
	TEN_DANG_NHAP NVARCHAR(100) PRIMARY KEY,
	MA_NGUOI_DUNG VARCHAR(10) NOT NULL,
	MAT_KHAU NVARCHAR(12) NOT NULL,
	VAI_TRO INT DEFAULT 0,
	--1:ADMIN,
	--0:STAFF
)
-------------------------------------------------------------------------------------------
CREATE TABLE NGUOI_DUNG
(
	MA_NGUOI_DUNG VARCHAR(10) PRIMARY KEY,
	TEN_NGUOI_DUNG NVARCHAR(100) NOT NULL,
	GIOI_TINH NVARCHAR(3),
	NGAY_SINH DATE,
	CCCD VARCHAR(12),
	DIA_CHI NVARCHAR(100),
	SDT VARCHAR(10)
)
ALTER TABLE TAI_KHOAN
ADD CONSTRAINT FK_MND FOREIGN KEY (MA_NGUOI_DUNG) REFERENCES NGUOI_DUNG(MA_NGUOI_DUNG)
-------------------------------------------------------------------------------------------
CREATE TABLE KHACH_HANG
(
	MA_KHACH_HANG VARCHAR(10) PRIMARY KEY,
	TEN_KHACH_HANG NVARCHAR(40),
	GIOI_TINH NVARCHAR(3),
	NGAY_SINH DATE,
	SO_LAN_MUA_HANG INT DEFAULT 0
)
-------------------------------------------------------------------------------------------
CREATE TABLE BAN 
--Thông tin vị trí số bàn xem có người đặt hay không
(
	MA_BAN INT PRIMARY KEY,
	TINH_TRANG_BAN NVARCHAR(100) NOT NULL
)
-------------------------------------------------------------------------------------------
CREATE TABLE CTDATBAN
(
	MA_DAT_BAN INT PRIMARY KEY,
	MA_BAN INT,
	MA_MON INT,
	CONSTRAINT FK_CTDATBAN_THUC_DON FOREIGN KEY(MA_MON) REFERENCES THUC_DON (MA_MON),
	CONSTRAINT FK_CTDATBAN_BAN FOREIGN KEY(MA_BAN) REFERENCES BAN(MA_BAN)
)
-------------------------------------------------------------------------------------------
CREATE TABLE DANH_MUC
(
	MA_DANH_MUC INT PRIMARY KEY,
	TEN_DANH_MUC NVARCHAR(30)
)
-------------------------------------------------------------------------------------------
CREATE TABLE THUC_DON
(
	MA_MON INT PRIMARY KEY,
	TEN_MON NVARCHAR(50),
	THANH_PHAN NVARCHAR(100),
	GIA INT,
	HINH_ANH VARCHAR(100),
	MA_DANH_MUC INT, 
	FOREIGN KEY (MA_DANH_MUC) REFERENCES DANH_MUC(MA_DANH_MUC)
)
-------------------------------------------------------------------------------------------
CREATE TABLE HOA_DON
(
	MA_HOA_DON INT PRIMARY KEY,
	MA_KHACH_HANG VARCHAR(10) NOT NULL,
	GIO_VAO DATETIME NOT NULL DEFAULT GETDATE(),
	GIO_RA DATETIME NOT NULL,
	TINH_TRANG_HD NVARCHAR(100) NOT NULL,
	THANH_TIEN REAL,
    MA_BAN INT,
	NGUOI_PHU_TRACH VARCHAR(10) NOT NULL,
	FOREIGN KEY (MA_KHACH_HANG) REFERENCES KHACH_HANG(MA_KHACH_HANG),
	FOREIGN KEY (NGUOI_PHU_TRACH) REFERENCES NGUOI_DUNG(MA_NGUOI_DUNG),
    FOREIGN KEY (MA_BAN) REFERENCES BAN(MA_BAN)
)
-------------------------------------------------------------------------------------------
CREATE TABLE CHI_TIET_HOA_DON
(
	MA_HOA_DON INT NOT NULL,
	MA_MON INT NOT NULL,
	COUNT INT NOT NULL DEFAULT 0,
	PRIMARY KEY (MA_HOA_DON, MA_MON),
	FOREIGN KEY (MA_HOA_DON) REFERENCES HOA_DON(MA_HOA_DON),
	FOREIGN KEY (MA_MON) REFERENCES THUC_DON(MA_MON)
)





------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------CONSTRAINT---------------------------------------------------------------------
CREATE TRIGGER Cap_Nhat_Thanh_Tien
ON CHI_TIET_HOA_DON
AFTER INSERT, DELETE
AS
BEGIN
    DECLARE @MaHoaDon INT;

    -- Xử lý khi có dữ liệu được chèn
    IF EXISTS (SELECT 1 FROM INSERTED)
    BEGIN
        SELECT @MaHoaDon = MA_HOA_DON FROM INSERTED;

        UPDATE HOA_DON
        SET THANH_TIEN = (
            SELECT ISNULL(SUM(THUC_DON.GIA * c.COUNT), 0)
            FROM CHI_TIET_HOA_DON c
            JOIN THUC_DON ON c.MA_MON = THUC_DON.MA_MON
            WHERE HOA_DON.MA_HOA_DON = c.MA_HOA_DON
        )
        WHERE HOA_DON.MA_HOA_DON = @MaHoaDon;
    END
    ELSE
    -- Xử lý khi có dữ liệu bị xóa
    IF EXISTS (SELECT 1 FROM DELETED)
    BEGIN
        SELECT @MaHoaDon = MA_HOA_DON FROM DELETED;

        UPDATE HOA_DON
        SET THANH_TIEN = (
            SELECT ISNULL(SUM(THUC_DON.GIA * c.COUNT), 0)
            FROM CHI_TIET_HOA_DON c
            JOIN THUC_DON ON c.MA_MON = THUC_DON.MA_MON
            WHERE HOA_DON.MA_HOA_DON = c.MA_HOA_DON
        )
        WHERE HOA_DON.MA_HOA_DON = @MaHoaDon;
    END;
END;
------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------INSERT DATA TO TABLE--------------------------------------------------------------
SET DATEFORMAT DMY
INSERT INTO NGUOI_DUNG (MA_NGUOI_DUNG, TEN_NGUOI_DUNG, GIOI_TINH, NGAY_SINH, CCCD, DIA_CHI, SDT) VALUES 
('ND0001', N'Nguyễn Văn Anh', N'Nam', '15/01/1990', '123456789012', 'Số 1, Đường Lạc Long Quân, Quận 1, TP.HCM', '0954218769'),
('ND0002', N'Trần Thị Bích', N'Nữ', '20/05/1995', '987654321098', 'Số 2, Đường Phổ Hiền, Quận 2, TP.HCM', '0987654321'),
('ND0003', N'Lê Văn Cường', N'Nam', '10/09/1998', '456789012345', 'Số 3, Đường Tôn Đức Thắng, Quận 3, TP.HCM', '0874289651'),
('ND0004', N'Phạm Thị Dung', N'Nữ', '25/03/1997', '321098765432', 'Số 4, Đường Tôn Đảng, Quận 4, TP.HCM', '0987654321'),
('ND0005', N'Hoàng Văn Hùng', N'Nam', '12/06/1998', '678901234567', 'Số 5, Đường Chiến Thắng, Quận 5, TP.HCM', '0579138536');
-------------------------------------------------------------------------------------------
INSERT INTO TAI_KHOAN (TEN_DANG_NHAP, MA_NGUOI_DUNG, MAT_KHAU, VAI_TRO) VALUES 
('user1', 'ND0001', 'password', 0), -- Vai trò 0 là nhân viên (STAFF)
('user2', 'ND0002', 'password', 0),
('user3', 'ND0003', 'password', 0),
('admin1', 'ND0004', 'admin', 1), -- Vai trò 1 là admin
('admin2', 'ND0005', 'admin', 1);
-------------------------------------------------------------------------------------------
INSERT INTO DANH_MUC VALUES
('1', 'Coffee'),
('2', 'Tea & Milk Tea'),
('3', 'Smoothie'),
('4', 'Cookies'),
('5', 'Macaron'),
('6', 'Donut')
-------------------------------------------------------------------------------------------
INSERT INTO THUC_DON VALUES
('1', 'Epresso', 'Concentrated coffe in small shot', 45000, 'Epresso.png', '1'),
('2', 'Americano', 'Espresso with hot water', 45000, 'Americano.png', '1'),
('3', 'Flat White', 'Espresso with steamed milk', 45000, 'FlatWhite.png', '1'),
('4', 'Latte', 'A latte is a shot of espresso topped with steamed milk and foam', 45000, 'Latte.png', '1'),
('5', 'Affogato', 'A scoop of ice cream is placed in a small cup, then warm, unsweetened coffee is poured over it', 45000, 'Affogato.png', '1'),
('6', 'Macchiato', 'A macchiato is equal parts espresso and steamed milk', 45000, 'Macchiato.png', '1'),
('7', 'Capucchino', 'A cappuccino is a shot of espresso with steamed milk', 45000, 'Capucchino.png', '1'),
('8', 'Milk Coffee', 'Coffee with hot water and milk then cooled with ice', 45000, 'cps.png', '1'),
--=========================================================================================================================================
('9', 'Black Sugar Milk Tea','The drink has tapioca balls in a brown sugar syrup, black tea, and milk', 65000, 'black sugar bubble milk.png', '2'),
('10', 'Herbal Tea','Made from plants, seeds, dried flowers by pouring boiling water', 30000, 'hbt.png', '2'),
('11', 'Southern Strawberry Iced Sweet Tea', 'Black tea and a simple strawberry syrup', 60000, 'Southern Strawberry Iced Sweet Tea.png', '2'),
('12', 'Peach Tea','Black tea, Mint leaves, Peaches', 45000, 'peach.png', '2'),
('13', 'Matcha Milk Tea','Matcha milk tea is a made from green tea powder, hot water, and milk', 60000, 'matcha latte.png', '2'),
('14', 'Honey Lemon Tea','Lemon juice, honey and hot water', 45000, 'Honey Lemon Tea.png', '2'),
('15', 'Olong Milk Tea','Oolong tea, milk, brown sugar, with black bubble', 45000, 'olong.png', '2'),
--=========================================================================================================================================
('16', 'Apple Banana Smoothie', 'Apple, banana peeled and chopped with orange juice and milk', 45000, 'apple banana.png', '3'),
('17', 'Apple Pie Smoothie', 'Apple, yogout, milk, cinnamon, honey, cream and rolled oats', 60000, 'apple pie.png', '3'),
('18', 'Berry Vanilla Smoothie', 'Frozen mixed berrie, vanilla protein powder, milk and water', 45000, 'berry vanilla.png', '3'),
('19', 'Chocolate Peanut Smoothie', 'Milk, honey, banana sliced and frozen, light creamy peanut butte and cocoa powder', 45000, 'chocolate peanut.png', '3'),
('20', 'Mango Tart Cherry Smoothie', 'Tart cherry juice, frozen mango chunks, and yogurt', 45000, 'mango tart cherry.png', '3'),
('21', 'Mocha Banana Smoothie', 'Bananas, espresso, almond milk, oats, honey and cocoa',50000, 'mocha banana.png', '3'),
('22', 'Pina Colada Smoothie', 'Rum, cream of coconut, pineapple juice and frozen pineapple', 55000, 'pina colada.png', '3'),
('23', 'Pumpkin Pie Smoothie', 'Pumpkin puree, banana, yogurt vanilla, pumpkin pie spice, honey, whipped cream and milk', 60000, 'pumpkin pie.png', '3'),
--=========================================================================================================================================
('24', 'Carrot Cream Cheese Cookies',NULL, 45000, 'carrot cream cheese.png', '4'),
('25', 'Chewy Ginger Molasses Cookies',NULL, 45000, 'Chewy Ginger Molasses Cookies.png', '4'),
('26', 'Choco Chip Cookies',NULL, 45000, 'choc chip cookies.png', '4'),
('27', 'Choco Mint',NULL, 45000, 'choco mint.png', '4'),
('28', 'Chocolate Chip Cookies',NULL, 45000, 'chocolate chip cookies.png', '4'),
('29', 'Chocolate Peanut Butter Cookies',NULL, 45000, 'Chocolate Peanut Butter Cookies.png', '4'),
('30', 'Lemon Cookies',NULL, 45000, 'lemon.png', '4'),
('31', 'Oatmeal Cookies',NULL, 45000, 'oatmeal cookies.png', '4'),
('32', 'Redvelvet Cookies',NULL, 45000, 'redvelvet.png', '4'),
('33', 'Strawberry Cookies',NULL, 45000, 'strawberry.png', '4'),
--=========================================================================================================================================
('34', 'Blueberry Cheesecake Macarons',NULL, 30000, 'Blueberry Cheesecake Macarons.png', '5'),
('35', 'Chocolate Macarons',NULL, 30000, 'Chocolate Macarons.png', '5'),
('36', 'Chocolate Orange Macarons',NULL, 30000, 'Chocolate Orange Macarons.png', '5'),
('37', 'Coconut Macarons',NULL, 30000, 'Coconut macarons.png', '5'),
('38', 'Green Tea Macarons',NULL, 30000, 'green tea macarons.png', '5'),
('39', 'Lavender Macarons',NULL, 30000, 'Lavender Macarons.png', '5'),
('40', 'Oreo Macarons	',NULL, 30000, 'Oreo Macarons.png', '5'),
('41', 'Salted Caramel Macarons',NULL, 30000, 'salted caramel macarons.png', '5'),
('42', 'Strawberry Cheesecake Macaron',NULL, 30000, 'Strawberry Cheesecake Macaron.png', '5'),
--=========================================================================================================================================
('43', 'Baked Orange Donuts with Salted Caramel Glaze',NULL, 30000, 'Baked Orange Donuts with Salted Caramel Glaze.png', '6'),
('44', 'Black Sesame Matcha Doughnuts',NULL, 30000, 'Black Sesame Matcha Doughnuts.png', '6'),
('45', 'Cinnamon Spiced Doughnuts',NULL, 30000, 'Cinnamon Spiced Doughnuts.png', '6'),
('46', 'Glazed Coconut Donuts',NULL, 30000, 'Glazed Coconut Donuts.png', '6'),
('48', 'Red Velvet Donuts',NULL, 30000, 'Red velvet donuts.png', '6'),
('49', 'Triple Chocolate Donuts',NULL, 30000, 'Triple Chocolate Donuts.png', '6'),
('50', 'Turmeric Lemon Coconut Donuts',NULL, 30000, 'Turmeric Lemon Coconut Donuts.png', '6'),
('51', 'Vegan Blueberry Donuts',NULL, 30000, 'Vegan Blueberry Donuts.png', '6'),
('52', 'Vegan Chai Latte Donuts With Maple Glaze',NULL, 30000, 'Vegan chai latte donuts with maple glaze.png', '6')
-------------------------------------------------------------------------------------------
INSERT INTO BAN VALUES
(1,N'Trống'),
(2,N'Trống'),
(3,N'Trống'),
(4,N'Đã đặt'),
(5,N'Trống'),
(6,N'Đã đặt'),
(7,N'Đã đặt'),
(8,N'Trống'),
(9,N'Đã đặt'),
(10,N'Đã đặt');
-------------------------------------------------------------------------------------------
SET DATEFORMAT DMY
-- Ví dụ với 10 dữ liệu mẫu, sửa lại ngày theo định dạng DMY
INSERT INTO KHACH_HANG (MA_KHACH_HANG, TEN_KHACH_HANG, GIOI_TINH, NGAY_SINH, SO_LAN_MUA_HANG)
VALUES
('KH001', N'Nguyễn Văn A', N'Nam', '15-05-1990', 2),
('KH002', N'Trần Thị B', N'Nữ', '22-08-1985', 5),
('KH003', N'Lê Văn C', N'Nam', '10-12-1995', 1),
('KH004', N'Phạm Thị D', N'Nữ', '25-03-1988', 3),
('KH005', N'Hoàng Văn E', N'Nam', '18-07-1992', 4),
('KH006', N'Nguyễn Thị F', N'Nữ', '30-09-1998', 1),
('KH007', N'Trần Văn G', N'Nam', '05-11-1997', 2),
('KH008', N'Lê Thị H', N'Nữ', '12-01-1994', 6),
('KH009', N'Phan Văn I', N'Nam', '20-04-1993', 2),
('KH010', N'Nguyễn Thị K', N'Nữ', '28-06-1996', 3);
-------------------------------------------------------------------------------------------
SET DATEFORMAT DMY
INSERT INTO HOA_DON (MA_HOA_DON, MA_KHACH_HANG, GIO_VAO, GIO_RA, TINH_TRANG_HD, THANH_TIEN, MA_BAN, NGUOI_PHU_TRACH)
VALUES
(1,'KH001', '2023-12-01 12:00:00', '2023-12-01 13:30:00', N'Hoàn thành', 150000, 1, 'ND0001'),
(2,'KH002', '2023-12-02 15:30:00', '2023-12-02 17:00:00', N'Chưa thanh toán', 200000, 2, 'ND0002'),
(3,'KH003', '2023-12-03 18:45:00', '2023-12-03 20:15:00', N'Đang chờ', 120000, 3, 'ND0003'),
(4,'KH004', '2023-12-04 10:00:00', '2023-12-04 11:30:00', N'Hoàn thành', 180000, 4, 'ND0004'),
(5,'KH005', '2023-12-05 14:45:00', '2023-12-05 16:00:00', N'Chưa thanh toán', 220000, 5, 'ND0005'),
(6,'KH006', '2023-12-06 19:30:00', '2023-12-06 21:00:00', N'Đang chờ', 130000, 6, 'ND0001'),
(7,'KH007', '2023-12-07 11:15:00', '2023-12-07 12:45:00', N'Hoàn thành', 160000, 7, 'ND0002'),
(8,'KH008', '2023-12-08 16:30:00', '2023-12-08 18:00:00', N'Chưa thanh toán', 190000, 8, 'ND0003'),
(9,'KH009', '2023-12-09 20:00:00', '2023-12-09 21:30:00', N'Đang chờ', 140000, 9, 'ND0004'),
(10,'KH010', '2023-12-10 13:00:00', '2023-12-10 14:15:00', N'Hoàn thành', 200000, 10, 'ND0005');
-------------------------------------------------------------------------------------------
INSERT INTO CHI_TIET_HOA_DON (MA_HOA_DON, MA_MON, COUNT) VALUES (1, 2, 2)
INSERT INTO CHI_TIET_HOA_DON (MA_HOA_DON, MA_MON, COUNT) VALUES (2, 2, 1)
INSERT INTO CHI_TIET_HOA_DON (MA_HOA_DON, MA_MON, COUNT) VALUES (3, 3, 3)
INSERT INTO CHI_TIET_HOA_DON (MA_HOA_DON, MA_MON, COUNT) VALUES	(4, 4, 2)
INSERT INTO CHI_TIET_HOA_DON (MA_HOA_DON, MA_MON, COUNT) VALUES (5, 5, 1)
INSERT INTO CHI_TIET_HOA_DON (MA_HOA_DON, MA_MON, COUNT) VALUES (6, 6, 3)
INSERT INTO CHI_TIET_HOA_DON (MA_HOA_DON, MA_MON, COUNT) VALUES	(7, 7, 2)
INSERT INTO CHI_TIET_HOA_DON (MA_HOA_DON, MA_MON, COUNT) VALUES (8, 8, 1)
INSERT INTO CHI_TIET_HOA_DON (MA_HOA_DON, MA_MON, COUNT) VALUES (9, 9, 3)
INSERT INTO CHI_TIET_HOA_DON (MA_HOA_DON, MA_MON, COUNT) VALUES	(10, 10, 2)


----------------------------------------------------------STORE PROCEDURE-----------------------------------------------------------------
--Thêm đơn hàng mới cùng với chi tiết của nó
CREATE PROCEDURE Them_Hoa_Don
(
    @GIO_RA DATETIME,
    @TINH_TRANG_HD NVARCHAR(100),
    @THANH_TIEN REAL,
    @MA_BAN INT,
    @NGUOI_PHU_TRACH VARCHAR(10),
    @MA_MON INT,
    @COUNT INT
)
AS
BEGIN
    DECLARE @MA_HOA_DON INT;

    -- Thêm hóa đơn mới
    INSERT INTO HOA_DON (GIO_VAO, GIO_RA, TINH_TRANG_HD, THANH_TIEN, MA_BAN, NGUOI_PHU_TRACH)
    VALUES (GETDATE(), @GIO_RA, @TINH_TRANG_HD, @THANH_TIEN, @MA_BAN, @NGUOI_PHU_TRACH);

    -- Lấy mã hóa đơn vừa thêm
    SET @MA_HOA_DON = SCOPE_IDENTITY();

    -- Thêm chi tiết hóa đơn
    INSERT INTO CHI_TIET_HOA_DON (MA_HOA_DON, MA_MON, COUNT)
    VALUES (@MA_HOA_DON, @MA_MON, @COUNT);
END;
-------------------------------------------------------------------------------------------
--Xóa hóa đơn và chi tiết hóa đơn liên quan
CREATE PROCEDURE Xoa_Hoa_Don 
	@MaHoaDon INT
AS
BEGIN
    DELETE FROM CHI_TIET_HOA_DON WHERE MA_HOA_DON = @MaHoaDon;
    DELETE FROM HOA_DON WHERE MA_HOA_DON = @MaHoaDon;
END;
-------------------------------------------------------------------------------------------
--Thủ tục để thêm một món vào thực đơn
CREATE PROCEDURE Them_Mon
	@maMon INT,
	@tenMon NVARCHAR(50),
	@thanhPhan NVARCHAR(100),
	@gia INT,
	@hinhAnh VARCHAR(100),
	@maDanhMuc INT
AS
BEGIN
    INSERT INTO THUC_DON (MA_MON, TEN_MON, THANH_PHAN, GIA, HINH_ANH, MA_DANH_MUC)
    VALUES (@maMon, @tenMon, @thanhPhan, @gia, @hinhAnh, @maDanhMuc)
END;
-------------------------------------------------------------------------------------------
--Thủ tục cập nhật món trên thực đơn
CREATE PROCEDURE Cap_Nhat_Mon
    @maMon INT,
    @tenMon NVARCHAR(50),
    @thanhPhan NVARCHAR(100),
    @gia INT,
    @hinhAnh VARCHAR(100),
    @maDanhMuc INT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM THUC_DON
        WHERE MA_MON = @maMon AND MA_DANH_MUC = @maDanhMuc
    )
    BEGIN
        UPDATE THUC_DON
        SET TEN_MON = @tenMon,
            THANH_PHAN = @thanhPhan,
            GIA = @gia,
            HINH_ANH = @hinhAnh,
            MA_DANH_MUC = @maDanhMuc
        WHERE MA_MON = @maMon
    END
    ELSE
    BEGIN
		PRINT N'Món vừa được thêm vào chưa tồn tại Mã Danh Mục !'
    END
END;
-------------------------------------------------------------------------------------------
--Lấy danh sách khách hàng theo giới tính
CREATE PROCEDURE Danh_Sach_Khach_Theo_Gioi_Tinh
    @Gender VARCHAR(10)
AS
BEGIN
    SELECT * FROM KHACH_HANG WHERE GIOI_TINH = @Gender;
END;
-------------------------------------------------------------------------------------------
--Cập nhật số lần mua theo mã khách hàng
CREATE PROCEDURE Cap_Nhat_So_Lan_Mua_Theo_Ma
    @MAKH INT,
    @SOLAN INT
AS
BEGIN
    UPDATE KHACH_HANG SET SO_LAN_MUA_HANG = @SOLAN WHERE @MAKH = MA_KHACH_HANG;
END;
-------------------------------------------------------------------------------------------
--Trả về người phụ trách của mã bàn
CREATE PROCEDURE Nguoi_Phu_Trach_Ban
    @MaBan INT
AS
BEGIN
    SELECT NGUOI_PHU_TRACH
    FROM HOA_DON
    WHERE HOA_DON.MA_BAN = @MaBan
END;
-------------------------------------------------------------------------------------------
--Cập nhật tình trạng bàn
CREATE PROCEDURE Cap_Nhat_Trang_Thai_Ban
    @MaBan INT,
    @TinhTrangBan NVARCHAR(50)
AS
BEGIN
    UPDATE Ban
    SET TINH_TRANG_BAN = @TinhTrangBan
    WHERE MA_BAN = @MaBan
END;
-------------------------------------------------------------------------------------------
-- Thêm người dùng mới 
CREATE PROCEDURE Them_Nguoi_Dung
    @p_MA_NGUOI_DUNG INT,
    @p_TEN_NGUOI_DUNG NVARCHAR(255),
    @p_GIOI_TINH CHAR(3),
    @p_NGAY_SINH DATE,
    @p_CCCD VARCHAR(12),
    @p_DIA_CHI NVARCHAR(255),
    @p_SDT VARCHAR(10)
AS
BEGIN
    INSERT INTO NGUOI_DUNG (MA_NGUOI_DUNG, TEN_NGUOI_DUNG, GIOI_TINH, NGAY_SINH, CCCD, DIA_CHI, SDT)
    VALUES (@p_MA_NGUOI_DUNG, @p_TEN_NGUOI_DUNG, @p_GIOI_TINH, @p_NGAY_SINH, @p_CCCD, @p_DIA_CHI, @p_SDT);
END;
------------------------------------------------------------------------------------------------------------------------------------------
-- Thủ tục cập nhật thông tin người dùng
CREATE PROCEDURE Cap_Nhat_Nguoi_Dung
    @p_MA_NGUOI_DUNG INT,
    @p_TEN_NGUOI_DUNG NVARCHAR(255),
    @p_GIOI_TINH CHAR(3),
    @p_NGAY_SINH DATE,
    @p_CCCD VARCHAR(12),
    @p_DIA_CHI NVARCHAR(255),
    @p_SDT VARCHAR(10)
AS
BEGIN
    UPDATE NGUOI_DUNG
    SET TEN_NGUOI_DUNG = @p_TEN_NGUOI_DUNG, GIOI_TINH = @p_GIOI_TINH, NGAY_SINH = @p_NGAY_SINH,
        CCCD = @p_CCCD, DIA_CHI = @p_DIA_CHI, SDT = @p_SDT
    WHERE MA_NGUOI_DUNG = @p_MA_NGUOI_DUNG;
END;
------------------------------------------------------------------------------------------------------------------------------------------
-- Câu thủ tục để thêm tài khoản mới 
CREATE PROCEDURE Them_Tai_Khoan
    @p_TEN_DANG_NHAP VARCHAR(255),
    @p_MAT_KHAU VARCHAR(255),
    @p_VAI_TRO VARCHAR(50),
    @p_MA_NGUOI_DUNG VARCHAR(10)
AS
BEGIN
    INSERT INTO TAI_KHOAN (TEN_DANG_NHAP, MAT_KHAU, VAI_TRO, MA_NGUOI_DUNG)
    VALUES (@p_TEN_DANG_NHAP, @p_MAT_KHAU, @p_VAI_TRO, @p_MA_NGUOI_DUNG);
END;
------------------------------------------------------------------------------------------------------------------------------------------
-- thủ tục cập nhật tài khoản
CREATE PROCEDURE CapNhatTaiKhoan
    @p_TEN_DANG_NHAP VARCHAR(255),
    @p_MAT_KHAU VARCHAR(255),
    @p_VAI_TRO VARCHAR(50)
AS 
BEGIN
    UPDATE TAI_KHOAN
    SET MAT_KHAU = @p_MAT_KHAU, VAI_TRO = @p_VAI_TRO
    WHERE TEN_DANG_NHAP = @p_TEN_DANG_NHAP;
END;



------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------FUNCTION-------------------------------------------------------------------
--Thêm đơn hàng mới cùng với chi tiết của nó
CREATE FUNCTION Lay_Chi_Tiet_Hoa_Don
    (@MaHoaDon INT)
RETURNS TABLE
AS
RETURN
(
    SELECT
        HD.MA_HOA_DON,
        HD.GIO_VAO,
        HD.GIO_RA,
        HD.TINH_TRANG_HD,
        HD.THANH_TIEN,
        HD.MA_BAN,
        HD.NGUOI_PHU_TRACH,
        CTHD.MA_MON,
        CTHD.COUNT
    FROM
        HOA_DON HD
    JOIN
        CHI_TIET_HOA_DON CTHD ON HD.MA_HOA_DON = CTHD.MA_HOA_DON
    WHERE
        HD.MA_HOA_DON = @MaHoaDon
);
-------------------------------------------------------------------------------------------
--Lấy danh sách hóa đơn theo trạng thái:
CREATE FUNCTION Lay_Danh_Sach_Hoa_Don_Theo_Trang_Thai
    (@TinhTrang NVARCHAR(100))
RETURNS TABLE
AS
RETURN
(
    SELECT *
    FROM HOA_DON
    WHERE TINH_TRANG_HD = @TinhTrang
);
-------------------------------------------------------------------------------------------
--Hàm để lấy tên danh mục dựa trên mã danh mục
CREATE FUNCTION Lay_Ten_Danh_Muc
(
	@maDanhMuc INT
)
RETURNS NVARCHAR(30)
AS
BEGIN
    DECLARE @tenDanhMuc NVARCHAR(30)

    SELECT @tenDanhMuc = TEN_DANH_MUC
    FROM DANH_MUC
    WHERE MA_DANH_MUC = @maDanhMuc

    RETURN @tenDanhMuc
END
-------------------------------------------------------------------------------------------
--Hàm đếm số lượng món trong danh mục 
CREATE FUNCTION Dem_So_Luong_Mon_Trong_Danh_Muc
(
    @maDanhMuc INT
)
RETURNS INT
AS
BEGIN
    DECLARE @soLuong INT;
    
    SELECT @soLuong = COUNT(*)
    FROM THUC_DON
    WHERE MA_DANH_MUC = @maDanhMuc;
    
    RETURN @soLuong;
END
-------------------------------------------------------------------------------------------
--Lấy ra danh sách khách hàng có số lần mua hàng lớn hơn một giá trị nào đó được đưa vào
CREATE FUNCTION Danh_Sach_So_Lan_Mua_Hang
(
	@SOLANMUA INT
)
RETURNS TABLE
AS
RETURN
    (SELECT * FROM KHACH_HANG WHERE SO_LAN_MUA_HANG > @SOLANMUA);
-------------------------------------------------------------------------------------------
--Tính tổng lần mua của khách hàng theo mã khách hàng ( đã fix )
CREATE FUNCTION Tong_So_Lan_Mua_Hang
(
	@MaKhachHang INT
)
RETURNS INT
AS
BEGIN
    DECLARE @TongLanMua INT;
    SELECT @TongLanMua = SUM(SO_LAN_MUA_HANG) FROM KHACH_HANG WHERE MA_KHACH_HANG = @MaKhachHang;
    RETURN @TongLanMua;
END
-------------------------------------------------------------------------------------------
--Đếm số lượng hóa đơn của bàn ( Xem lại vì 1 bàn thì chỉ có 1 hóa đơn ? )
CREATE FUNCTION DemHoaDon
    (@MaBan INT)
RETURNS INT
AS
BEGIN
    DECLARE @Dem INT;
    SET @Dem = (SELECT COUNT(*) FROM HOA_DON WHERE MA_BAN = @MaBan);
    RETURN @dem;
END;
-------------------------------------------------------------------------------------------
--Trả về trạng thái của bàn
CREATE FUNCTION Tra_Ve_Tinh_Trang_Ban
(
	@TinhTrangBan NVARCHAR(50)
)
RETURNS TABLE
AS
RETURN (
    SELECT MA_BAN, TINH_TRANG_BAN
    FROM Ban
    WHERE TINH_TRANG_BAN = @TinhTrangBan
)
-------------------------------------------------------------------------------------------
-- Hàm lấy tên theo mã người dùng
CREATE FUNCTION Lay_Ten_Nguoi_Dung_Theo_Ma_Nguoi_Dung
(
	@p_MA_NGUOI_DUNG INT
)
RETURNS NVARCHAR(255)
AS
BEGIN
    DECLARE @v_TEN_NGUOI_DUNG NVARCHAR(255);
    SELECT @v_TEN_NGUOI_DUNG = TEN_NGUOI_DUNG
    FROM NGUOI_DUNG
    WHERE MA_NGUOI_DUNG = @p_MA_NGUOI_DUNG;
    RETURN @v_TEN_NGUOI_DUNG;
END;
-------------------------------------------------------------------------------------------
--Hàm tính tuổi
CREATE FUNCTION Tinh_Tuoi(@p_NGAY_SINH DATE)
RETURNS INT
AS
BEGIN
    DECLARE @v_TUOI INT;
    SET @v_TUOI = DATEDIFF(YEAR, @p_NGAY_SINH, GETDATE());

    IF (DATEADD(YEAR, @v_TUOI, @p_NGAY_SINH) > GETDATE())
        SET @v_TUOI = @v_TUOI - 1;
    RETURN @v_TUOI;
END
------------------------------------------------------------------------------------------------------------------------------------------
-- Lấy tên người dùng theo tên đăng nhập
CREATE FUNCTION Lay_Ten_Nguoi_Dung_Theo_Ten_Dang_Nhap(@p_TEN_DANG_NHAP VARCHAR(255))
RETURNS NVARCHAR(255)
AS
BEGIN
    DECLARE @v_TEN_NGUOI_DUNG NVARCHAR(255);
    SELECT @v_TEN_NGUOI_DUNG = ND.TEN_NGUOI_DUNG
    FROM TAI_KHOAN AS TK
    JOIN NGUOI_DUNG AS ND ON TK.MA_NGUOI_DUNG = ND.MA_NGUOI_DUNG
    WHERE TK.TEN_DANG_NHAP = @p_TEN_DANG_NHAP;
    RETURN @v_TEN_NGUOI_DUNG;
END;
------------------------------------------------------------------------------------------------------------------------------------------
-- Hàm lấy vai trò dựa vào tên đăng nhập
CREATE FUNCTION Lay_Vai_Tro_Theo_Ten_Dang_Nhap(@p_TEN_DANG_NHAP VARCHAR(255))
RETURNS VARCHAR(50)
AS
BEGIN
    DECLARE @v_VAI_TRO VARCHAR(50);
    SELECT @v_VAI_TRO = VAI_TRO
    FROM TAI_KHOAN
    WHERE TEN_DANG_NHAP = @p_TEN_DANG_NHAP;
    RETURN @v_VAI_TRO;
END





------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------CURSOR--------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
--In ra thông tin của từng món
DECLARE @maMon INT;
DECLARE @tenMon NVARCHAR(50);
DECLARE cursorMon CURSOR FOR
SELECT MA_MON, TEN_MON
FROM THUC_DON;

OPEN cursorMon;

FETCH NEXT FROM cursorMon INTO @maMon, @tenMon;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Mã món: ' + CAST(@maMon AS NVARCHAR(10));
    PRINT 'Tên món: ' + @tenMon;
    PRINT '-------------------------------------';

    FETCH NEXT FROM cursorMon INTO @maMon, @tenMon;
END;

CLOSE cursorMon;
DEALLOCATE cursorMon;
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
--cursor de lap qua tat ca ban ghi trong bang KhachHang va hien thi thong tin
DECLARE @Ma_khach_hang INT
DECLARE @Ten_khach_hang NVARCHAR(50)
DECLARE @Gioi_tinh NVARCHAR(10)
DECLARE @Ngay_sinh DATE
DECLARE @So_lan_mua_hang INT

DECLARE Hienthithongtin CURSOR FOR
SELECT Ma_khach_hang, Ten_khach_hang, Gioi_tinh, Ngay_sinh, So_lan_mua_hang
FROM KHACH_HANG

OPEN Hienthithongtin
FETCH NEXT FROM Hienthithongtin INTO @Ma_khach_hang, @Ten_khach_hang, @Gioi_tinh, @Ngay_sinh, @So_lan_mua_hang

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Mã khách hàng: ' + CONVERT(NVARCHAR(10), @Ma_khach_hang)
    PRINT 'Tên khách hàng: ' + @Ten_khach_hang
    PRINT 'Giới tính: ' + @Gioi_tinh
    PRINT 'Ngày sinh: ' + CONVERT(NVARCHAR(10), @Ngay_sinh, 103)
    PRINT 'Số lần mua hàng: ' + CONVERT(NVARCHAR(10), @So_lan_mua_hang)

    FETCH NEXT FROM Hienthithongtin INTO @Ma_khach_hang, @Ten_khach_hang, @Gioi_tinh, @Ngay_sinh, @So_lan_mua_hang
END

CLOSE Hienthithongtin
DEALLOCATE Hienthithongtin
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
--cursor tinh tong so lan mua hang
DECLARE @Ma_khach_hang1 INT
DECLARE @So_lan_mua_hang1 INT
DECLARE @TongSoLanMuaHang INT

SET @TongSoLanMuaHang = 0

DECLARE TongCursor CURSOR FOR
SELECT Ma_khach_hang, So_lan_mua_hang
FROM Khach_hang

OPEN TongCursor
FETCH NEXT FROM TongCursor INTO @Ma_khach_hang1, @So_lan_mua_hang1

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @TongSoLanMuaHang = @TongSoLanMuaHang + @So_lan_mua_hang1

    FETCH NEXT FROM TongCursor INTO @Ma_khach_hang1, @So_lan_mua_hang1
END

CLOSE TongCursor
DEALLOCATE TongCursor

PRINT 'Tổng số lần mua hàng của tất cả khách hàng là: ' + CONVERT(NVARCHAR(10), @TongSoLanMuaHang)
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
--Cursor để lấy danh sách người dùng
DECLARE NguoiDungCursor CURSOR FOR
SELECT MA_NGUOI_DUNG, TEN_NGUOI_DUNG, GIOI_TINH, NGAY_SINH, CCCD, DIA_CHI, SDT
FROM NGUOI_DUNG;

DECLARE @v_MA_NGUOI_DUNG INT;
DECLARE @v_TEN_NGUOI_DUNG NVARCHAR(255);
DECLARE @v_GIOI_TINH CHAR(3);
DECLARE @v_NGAY_SINH DATE;
DECLARE @v_CCCD VARCHAR(20);
DECLARE @v_DIA_CHI NVARCHAR(255);
DECLARE @v_SDT VARCHAR(15);

OPEN NguoiDungCursor;

FETCH NEXT FROM NguoiDungCursor INTO @v_MA_NGUOI_DUNG, @v_TEN_NGUOI_DUNG, @v_GIOI_TINH, @v_NGAY_SINH, @v_CCCD, @v_DIA_CHI, @v_SDT;
WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT N'Mã người dùng: ' + CAST(@v_MA_NGUOI_DUNG AS NVARCHAR(10));
    PRINT N'Tên người dùng: ' + @v_TEN_NGUOI_DUNG;
    PRINT N'Giới tính: ' + @v_GIOI_TINH;
    PRINT N'Ngày sinh: ' + CAST(@v_NGAY_SINH AS NVARCHAR(10));
    PRINT 'CCCD: ' + @v_CCCD;
    PRINT N'Địa chỉ: ' + @v_DIA_CHI;
    PRINT N'Số điện thoại: ' + @v_SDT;
    FETCH NEXT FROM NguoiDungCursor INTO @v_MA_NGUOI_DUNG, @v_TEN_NGUOI_DUNG, @v_GIOI_TINH, @v_NGAY_SINH, @v_CCCD, @v_DIA_CHI, @v_SDT;
END;

CLOSE NguoiDungCursor;
DEALLOCATE NguoiDungCursor;
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
--Cursor để lấy thông tin người dùng dựa vào mã người dùng
DECLARE NguoiDungTheoMaNguoiDungCursor CURSOR FOR
SELECT MA_NGUOI_DUNG, TEN_NGUOI_DUNG, GIOI_TINH, NGAY_SINH, CCCD, DIA_CHI, SDT
FROM NGUOI_DUNG
WHERE MA_NGUOI_DUNG = 123
;

DECLARE @v_MA_NGUOI_DUNG INT;
DECLARE @v_TEN_NGUOI_DUNG NVARCHAR(255);
DECLARE @v_GIOI_TINH CHAR(1);
DECLARE @v_NGAY_SINH DATE;
DECLARE @v_CCCD VARCHAR(20);
DECLARE @v_DIA_CHI NVARCHAR(255);
DECLARE @v_SDT VARCHAR(15);

OPEN NguoiDungTheoMaNguoiDungCursor;

FETCH NEXT FROM NguoiDungTheoMaNguoiDungCursor INTO @v_MA_NGUOI_DUNG, @v_TEN_NGUOI_DUNG, @v_GIOI_TINH, @v_NGAY_SINH, @v_CCCD, @v_DIA_CHI, @v_SDT;

IF @@FETCH_STATUS = 0
BEGIN
    PRINT N'Mã người dùng: ' + CAST(@v_MA_NGUOI_DUNG AS NVARCHAR(10));
    PRINT N'Tên người dùng: ' + @v_TEN_NGUOI_DUNG;
    PRINT N'Giới tính: ' + @v_GIOI_TINH;
    PRINT N'Ngày sinh: ' + CAST(@v_NGAY_SINH AS NVARCHAR(10));
    PRINT 'CCCD: ' + @v_CCCD;
    PRINT N'Địa chỉ: ' + @v_DIA_CHI;
    PRINT N'Số điện thoại: ' + @v_SDT;
END
ELSE
BEGIN
    PRINT N'Không tìm thấy người dùng với mã người dùng cụ thể.';
END;

CLOSE NguoiDungTheoMaNguoiDungCursor;
DEALLOCATE NguoiDungTheoMaNguoiDungCursor;
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-- Danh sách tài khoản và thông tin người dùng
DECLARE TaiKhoanNguoiDungCursor CURSOR FOR
    SELECT
        TK.TEN_DANG_NHAP, TK.MA_NGUOI_DUNG, TK.MAT_KHAU, TK.VAI_TRO,
        ND.TEN_NGUOI_DUNG, ND.GIOI_TINH, ND.NGAY_SINH, ND.CCCD, ND.DIA_CHI, ND.SDT
    FROM TAI_KHOAN AS TK
    INNER JOIN NGUOI_DUNG AS ND ON TK.MA_NGUOI_DUNG = ND.MA_NGUOI_DUNG;

	DECLARE @v_TEN_DANG_NHAP NVARCHAR(255);
    DECLARE @v_MA_NGUOI_DUNG INT;
    DECLARE @v_MAT_KHAU NVARCHAR(255);
    DECLARE @v_VAI_TRO VARCHAR(50);
    DECLARE @v_TEN_NGUOI_DUNG NVARCHAR(255);
    DECLARE @v_GIOI_TINH CHAR(3);
    DECLARE @v_NGAY_SINH DATE;
    DECLARE @v_CCCD VARCHAR(20);
    DECLARE @v_DIA_CHI NVARCHAR(255);
    DECLARE @v_SDT VARCHAR(15);

	OPEN TaiKhoanNguoiDungCursor;
	FETCH NEXT FROM TaiKhoanNguoiDungCursor INTO
        @v_TEN_DANG_NHAP, @v_MA_NGUOI_DUNG, @v_MAT_KHAU, @v_VAI_TRO,
        @v_TEN_NGUOI_DUNG, @v_GIOI_TINH, @v_NGAY_SINH, @v_CCCD, @v_DIA_CHI, @v_SDT;
	WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT N'Tên đăng nhập: ' + @v_TEN_DANG_NHAP;
        PRINT N'Mã người dùng: ' + CAST(@v_MA_NGUOI_DUNG AS NVARCHAR(10));
        PRINT N'Mật khẩu: ' + @v_MAT_KHAU;
        PRINT N'Vai trò: ' + @v_VAI_TRO;
        PRINT N'Tên người dùng: ' + @v_TEN_NGUOI_DUNG;
        PRINT N'Giới tính: ' + @v_GIOI_TINH;
        PRINT N'Ngày sinh: ' + CAST(@v_NGAY_SINH AS NVARCHAR(10));
        PRINT 'CCCD: ' + @v_CCCD;
        PRINT N'Địa chỉ: ' + @v_DIA_CHI;
        PRINT N'Số điện thoại: ' + @v_SDT;

        FETCH NEXT FROM TaiKhoanNguoiDungCursor INTO
            @v_TEN_DANG_NHAP, @v_MA_NGUOI_DUNG, @v_MAT_KHAU, @v_VAI_TRO,
            @v_TEN_NGUOI_DUNG, @v_GIOI_TINH, @v_NGAY_SINH, @v_CCCD, @v_DIA_CHI, @v_SDT;
    END;

    CLOSE TaiKhoanNguoiDungCursor;
    DEALLOCATE TaiKhoanNguoiDungCursor;