extends GutTest

func before_all():
    gut.p("EffectStack 测试套件初始化")

func test_placeholder():
    assert_true(true, "EffectStack 冒烟占位测试")
