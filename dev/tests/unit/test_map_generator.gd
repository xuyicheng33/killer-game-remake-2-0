extends GutTest

func before_all():
    gut.p("MapGenerator 测试套件初始化")

func test_placeholder():
    assert_true(true, "MapGenerator 冒烟占位测试")
