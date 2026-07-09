from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import Paragraph, SimpleDocTemplate, Spacer, Table, TableStyle


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "output" / "pdf"
OUT.mkdir(parents=True, exist_ok=True)
PDF_PATH = OUT / "MoonRedactKit_项目申报书.pdf"


def register_font():
    candidates = [
        Path("C:/Windows/Fonts/msyh.ttc"),
        Path("C:/Windows/Fonts/simhei.ttf"),
        Path("C:/Windows/Fonts/simsun.ttc"),
    ]
    for font in candidates:
        if font.exists():
            pdfmetrics.registerFont(TTFont("CN", str(font)))
            return "CN"
    return "Helvetica"


FONT = register_font()
styles = getSampleStyleSheet()
title = ParagraphStyle(
    "TitleCN",
    parent=styles["Title"],
    fontName=FONT,
    fontSize=18,
    leading=24,
    textColor=colors.HexColor("#18324A"),
    alignment=1,
    spaceAfter=10,
)
heading = ParagraphStyle(
    "HeadingCN",
    parent=styles["Heading2"],
    fontName=FONT,
    fontSize=12,
    leading=16,
    textColor=colors.HexColor("#245B83"),
    spaceBefore=6,
    spaceAfter=4,
)
body = ParagraphStyle(
    "BodyCN",
    parent=styles["BodyText"],
    fontName=FONT,
    fontSize=9.2,
    leading=13.5,
    firstLineIndent=0,
    spaceAfter=4,
)
small = ParagraphStyle(
    "SmallCN",
    parent=body,
    fontSize=8.4,
    leading=12,
)


def p(text, style=body):
    return Paragraph(text.replace("\n", "<br/>"), style)


def info_table(rows):
    table = Table(
        [[p(k, small), p(v, small)] for k, v in rows],
        colWidths=[32 * mm, 132 * mm],
        hAlign="LEFT",
    )
    table.setStyle(
        TableStyle(
            [
                ("FONTNAME", (0, 0), (-1, -1), FONT),
                ("GRID", (0, 0), (-1, -1), 0.25, colors.HexColor("#B7C6D1")),
                ("BACKGROUND", (0, 0), (0, -1), colors.HexColor("#EEF5F8")),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("LEFTPADDING", (0, 0), (-1, -1), 6),
                ("RIGHTPADDING", (0, 0), (-1, -1), 6),
                ("TOPPADDING", (0, 0), (-1, -1), 4),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
            ]
        )
    )
    return table


story = [p("MoonRedactKit 项目申报书", title)]

story.append(
    info_table(
        [
            ("项目名称", "MoonRedactKit：面向 MoonBit 的敏感信息识别、脱敏与审计安全基础库"),
            ("参赛者", "庄源"),
            ("联系方式", "15778849490"),
            ("GitHub 仓库", "https://github.com/xvkong834/MoonRedactKit"),
            ("GitLink 仓库", "https://www.gitlink.org.cn/zy66668/MoonRedactKit"),
            ("项目方向", "MoonBit 安全工程基础库 / 日志与事件隐私保护"),
            ("是否移植项目", "否，原创 MoonBit 基础库"),
        ]
    )
)
story.append(Spacer(1, 6))

sections = [
    (
        "一、项目简介",
        "MoonRedactKit 面向 MoonBit 生态提供敏感信息识别、策略化脱敏、审计摘要和泄漏门禁能力。"
        "它可嵌入日志库、CI、SDK 诊断、事件导出、测试快照和数据交换流程，在数据离开可信边界前识别邮箱、手机号、身份证、银行卡、token、secret marker、IP 等风险内容，并按策略输出安全文本和机器可读审计结果。",
    ),
    (
        "二、核心价值",
        "MoonBit 生态已经有结构化日志、Schema 校验等项目，但缺少专门的隐私红线与脱敏决策核心。"
        "本项目不做日志采集、存储或 UI，而是补齐日志和事件链路中的安全前置层：先判断内容是否可输出，再决定如何脱敏，并把决策过程留给 CI、审计或上层平台复核。",
    ),
    (
        "三、已实现功能",
        "1. 纯 MoonBit 文本扫描器，支持邮箱、手机号、身份证、银行卡、token、secret marker、IP 地址等类型。<br/>"
        "2. RedactPolicy 策略模型，支持 full、keep_prefix_suffix、hash_label、drop、pass 等脱敏模式。<br/>"
        "3. RedactResult、RedactSummary、GateResult、BatchReport 等审计结构，可直接用于 CI 或发布门禁。<br/>"
        "4. 字段路径评估能力，可对结构化事件中的 user.email、auth.token 等路径做策略检查。<br/>"
        "5. JSON 导出、CLI 演示、12 个回归测试、跨平台 GitHub Actions CI。",
    ),
    (
        "四、创新点",
        "项目把脱敏从临时字符串替换提升为可复用的隐私决策模型：检测结果带类型、置信度和来源；策略按敏感类型配置；批处理和门禁可把高风险输出阻断在 CI、日志出口或 SDK 调试边界。"
        "这种设计更接近工业数据安全链路，适合成为 MoonBit 安全工程生态的底层积木。",
    ),
    (
        "五、技术路线",
        "核心算法保持零依赖和后端中立，不依赖浏览器、Node、系统 IO 或正则运行时。"
        "检测器采用确定性扫描和边界判断；策略层负责类型到脱敏动作的映射；审计层输出 summary/gate/batch JSON，便于接入 CLI、CI、日志库和服务治理工具。",
    ),
    (
        "六、与社区项目差异",
        "mooncakes 上已有 JSON Schema、Zod 风格校验、结构化日志和 tracing 类项目。MoonRedactKit 的边界不同："
        "它不校验数据结构，也不负责发日志，而是在日志或事件发出前识别敏感内容、执行脱敏策略并生成审计门禁结果。"
    ),
    (
        "七、阶段计划",
        "第一阶段完善规则覆盖和测试样例；第二阶段增加更多国家/地区标识、低误报 token 评分、字段策略模板和差异测试；"
        "第三阶段补充与日志库、HTTP SDK、CI secret scan、测试快照工具的集成示例。",
    ),
    (
        "八、验收说明",
        "仓库围绕公开代码持续开发，提交记录按基础架构、核心类型、检测器、策略、门禁、文档测试拆分。"
        "当前项目包含完整 MoonBit 源码、README、RELATED_WORK、ACCEPTANCE、CI、CLI 示例和正式申报书，可直接用于报名初审与后续迭代。",
    ),
]

for name, text in sections:
    story.append(p(name, heading))
    story.append(p(text))

doc = SimpleDocTemplate(
    str(PDF_PATH),
    pagesize=A4,
    rightMargin=18 * mm,
    leftMargin=18 * mm,
    topMargin=16 * mm,
    bottomMargin=16 * mm,
)
doc.build(story)
print(PDF_PATH)

