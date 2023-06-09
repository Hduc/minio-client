/****** Script for SelectTopNRows command from SSMS  ******/
select top 10* from [Y_B_DMHH Quy Doi]-- BOM
select top 10* from [Y_B_DMNHOMCT] --Bo
select top 10* from [Y_B_DM hoa van]-- Hoa van 

select * from y_b_dmhh order by Y_B_DMHH.MAKH where MAKH='063595000' -- DM SP
select * from [Y_B_DMHH Quy Doi] where mahh = '0000000000079' -- BOM
select * from [Y_B_DMHH Quy Doi] where MAHHCT in ('0000000000081', '0000000038996' )
select * from y_b_dmhh where mahh in ('0000000000079', '0000000000082')-- DM SP

select * from y_b_dmhh where mahh in (select mahhct from [Y_B_DMHH Quy Doi] where mahh in ('0000000000079', '0000000000082'))-- DM 5P
--select * from [Y_B_DMHH Quy Doi] where mahh in ('0000000000079', '0000000000082')-- DM SP


select * from Y_B_DMNHOM where MANHOM ='00033'
--select * from Y_B_DMNHOM where MaPNhom ='TP'

select top 10 * from [Y_B_DM hoa van]-- Hoa vän
where MaHoaVan = '000'
select top 10 * from [Y_B_DMNHOMCT] --Bo
where MaNhomCt = '00011'
select * from Y_B_DMThuongHieu th -- Thương hiệu
where  th.MaThuongHieu = 'ML'

select MaHoaVan,count (distinct MANhomCT) from y_b_dmhh group by MaHoaVan having count (distinct MANhomCT)>1 
select MANhomCT, count (distinct MaHoaVan) from y_b_dmhh group by MANhomCT having count (distinct MaHoaVan)>1

------------------------------------------------------------------------------------
SELECT*
		--[MAHH]
  --    ,[Name]
  --    ,[MaHoaVan] --ma hoa van
	 -- ,[MANhomCT] -- ma bo
  FROM [MMS].[dbo].[Y_B_DMHH]

select top 100 MaHoaVan, TenHoaVan, MaBo from [MMS].[dbo].[Y_B_DM hoa van]

select top 100 * from [MMS].[dbo].[Y_B_DMNHOMCT]

select sanpham.MAHH as Id, sanpham.Name as Name, bo.MaThuongHieu as ThuonghieuId, bo.MaThuongHieu as ThuonghieuName, bo.MaNhomCt as BoId, bo.Name as BoName, hv.MaHoaVan as HoavanId, hv.TenHoaVan as HoavanName
from [Y_B_DMHH] sanpham 
join [Y_B_DM hoa van] hv on sanpham.MaHoaVan=hv.MaHoaVan 
join [Y_B_DMNHOMCT] bo on sanpham.MANhomCT = bo.MaNhomCt 
join [Y_B_DMThuongHieu] th on th.MaThuongHieu = bo.MaThuongHieu
where
th.MaThuongHieu = 'KS'
 sanpham.mahh='0000000000079'


select th.MaThuongHieu as Id, th.TenThuongHieu as Name from [Y_B_DMThuongHieu] th
select bo.MaNhomCt as Id, bo.Name as Name, bo.MaThuongHieu from [Y_B_DMNHOMCT] bo 
select hv.MaHoaVan as Id, hv.TenHoaVan as Name from [Y_B_DM hoa van] hv

ALTER PROCEDURE [dbo].[SP_SearchSanPham]
@MaTH nvarchar(Max) = '-1'		  ,
@MaBo nvarchar(Max) = '-1'		  ,
@MaHoaVan nvarchar(Max) = '-1'	  ,
@Keyword nvarchar(Max) = '',
@PageSize int = 5				 ,
@PageIndex int = 1				 ,
@IsExistFile int = -1,---1=notUse, 0 = false, 1 = true
@ProductIDs VARCHAR(MAX) = ''
as
begin

    -- Tạo một bảng tạm để lưu trữ danh sách ID sản phẩm
    DECLARE @IDsTable TABLE (ProductID NVARCHAR(MAX));

    -- Chuyển đổi danh sách ID thành các dòng trong bảng tạm
    INSERT INTO @IDsTable (ProductID)
    SELECT value
    FROM  dbo.SplitString(@ProductIDs, ',');

with list as(


	select  ROW_NUMBER() OVER (ORDER BY sanpham.MAKH ) as Row
		,COUNT(sanpham.MAKH ) over() as TotalRow,  
		sanpham.MAKH as Id, sanpham.Name as Name, bo.MaThuongHieu as ThuonghieuId, th.TenThuongHieu as ThuonghieuName, bo.MaNhomCt as BoId, bo.Name as BoName, hv.MaHoaVan as HoavanId, hv.TenHoaVan as HoavanName
	from [Y_B_DMHH] sanpham 
	join [Y_B_DM hoa van] hv on sanpham.MaHoaVan=hv.MaHoaVan 
	join [Y_B_DMNHOMCT] bo on sanpham.MANhomCT = bo.MaNhomCt  
	join [Y_B_DMThuongHieu] th on th.MaThuongHieu = bo.MaThuongHieu
	where 1=1
	and (@MaTH='-1' or bo.MaThuongHieu = @MaTH)
	and (@MaBo='-1' or sanpham.MaNhomCt = @MaBo)
	and (@MaHoaVan='-1' or sanpham.MaHoaVan = @MaHoaVan)
	and (sanpham.MAKH like '%'+ @Keyword +'%' or sanpham.[Name] like '%'+ @Keyword +'%' )
	and ( @IsExistFile not in (1) or sanpham.MAKH IN (SELECT ProductID FROM @IDsTable))
	and (@IsExistFile not in (0) or sanpham.MAKH NOT IN (SELECT ProductID FROM @IDsTable))

)
select ls.* from list ls where  ls.row between (@PageSize*(@PageIndex-1)+1) and @PageSize*@PageIndex 
end
return 

exec [dbo].[SP_SearchSanPham] '-1', '-1', '-1','',5,1, 1, '012009000,042214014'


CREATE FUNCTION dbo.SplitString
(
    @String VARCHAR(MAX),
    @Delimiter CHAR(1)
)
RETURNS @Result TABLE (Value VARCHAR(MAX))
AS
BEGIN
    DECLARE @StartIndex INT, @EndIndex INT

    SET @StartIndex = 1
    IF SUBSTRING(@String, LEN(@String) - 1, LEN(@String)) <> @Delimiter
    BEGIN
        SET @String = @String + @Delimiter
    END

    WHILE CHARINDEX(@Delimiter, @String) > 0
    BEGIN
        SET @EndIndex = CHARINDEX(@Delimiter, @String)
        INSERT INTO @Result (Value)
        SELECT SUBSTRING(@String, @StartIndex, @EndIndex - @StartIndex)
        SET @String = SUBSTRING(@String, @EndIndex + 1, LEN(@String))
    END

    RETURN
END
GO



  DECLARE  @ProductIDs VARCHAR(MAX) = '0000000000001,0000000000068'
    -- Tạo một bảng tạm để lưu trữ danh sách ID sản phẩm
    DECLARE @IDsTable TABLE (ProductID INT);

    -- Chuyển đổi danh sách ID thành các dòng trong bảng tạm
    INSERT INTO @IDsTable (ProductID)
    SELECT value
    FROM  dbo.SplitString(@ProductIDs, ',');

    -- Select các dòng sản phẩm tương ứng từ bảng sản phẩm
    SELECT *
    FROM [Y_B_DMHH] sp
    WHERE sp.MAHH NOT IN (SELECT ProductID FROM @IDsTable);
