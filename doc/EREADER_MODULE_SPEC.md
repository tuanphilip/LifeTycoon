# KIẾN TRÚC & TRIỂN KHAI TRÌNH ĐỌC NÂNG CAO (EPUB & PDF) NHƯ READERA (LifeTycoon)

Tài liệu này đặc tả toàn bộ kiến trúc kỹ thuật để xây dựng bộ E-Reader trong Flutter đạt trải nghiệm mượt mà tương đương **ReadEra** (Offline 100%, render nhanh, tùy biến giao diện đọc sâu, bookmark, TTS và tích hợp tracking chống cheat).

---

## 1. So sánh Lựa chọn Kỹ thuật (Technical Stack Selection)

Để đạt hiệu năng như ReadEra (không giật lag, mở được file sách nặng 100MB+), chúng ta chọn các thư viện tối ưu nhất:

| Định dạng | Thư viện đề xuất | Ưu điểm & Tính năng hỗ trợ |
| :--- | :--- | :--- |
| **PDF** | **`pdfx: ^2.6.0`** (Dựa trên Pdfium C++) | Render trang thành bitmap siêu tốc bằng C++, hỗ trợ pinch-to-zoom, jump page, thumbnail preview, text search. |
| **EPUB** | **`epubx: ^3.1.3`** + **`flutter_html`** (hoặc Native WebView engine) | Parse cấu trúc OPF/NCX thuần Dart, trích xuất TOC (mục lục), chia trang động (pagination) theo kích thước màn hình. |
| **Text-to-Speech (TTS)** | **`flutter_tts: ^4.0.2`** | Đọc sách rảnh tay bằng giọng đọc offline của hệ điều hành (Siri / Google TTS). |
| **File Storage / SAF** | **`file_picker: ^8.0.3`** | Chọn file từ thẻ nhớ/Google Drive qua Storage Access Framework chuẩn Store. |

---

## 2. Các Tính năng Nâng cao Chuẩn ReadEra Cần có

1. **Chế độ hiển thị (Reading Modes):**
   * Chế độ lật trang (Page Curl / Horizontal Slide).
   * Chế độ cuộn dọc liên tục (Vertical Continuous Scroll) — cực kỳ phù hợp cho tài liệu PDF/báo cáo.
2. **Tùy biến Visual (Themes & Typography):**
   * 4 Theme nền: **Dark OLED (`#0D0F12`)**, **Sepia/Vàng dịu (`#F4ECD8`)**, **White (`#FFFFFF`)**, **Light Slate (`#E2E8F0`)**.
   * Chỉnh cỡ chữ (Font size), khoảng cách dòng (Line height), lề trang (Margins), đổi font chữ (Serif, Sans-serif, OpenDyslexic).
3. **Quản lý Tiến độ & Đánh dấu (Navigation & Bookmarks):**
   * Bảng mục lục chương (Table of Contents - TOC).
   * Lưu vị trí đọc cuối cùng chính xác đến từng đoạn văn (CFI đối với EPUB, Trang đối với PDF).
   * Đánh dấu trang (Bookmarks), Highlight văn bản (4 màu), Ghi chú (Notes).
4. **Tìm kiếm Văn bản (In-Book Search):**
   * Tìm từ khóa trong toàn bộ cuốn sách kèm vị trí trang và preview ngữ cảnh.
5. **Text-to-Speech (Đọc thành tiếng):**
   * Cho phép vừa nghe sách vừa đi bộ (vừa cày điểm INT vừa cày điểm STA trong game).

---

## 3. Tích hợp Cơ chế Game & Chống Cheat (Gamified Tracking Logic)

Để biến việc đọc sách thành tiền và điểm Trí Tuệ (INT) trong LifeTycoon:

```text
┌─────────────────────────────────────────────────────────────────┐
│                      E-READER VIEWPORT                          │
│                                                                 │
│  [Trang 45/320]   Thời gian trang: 00:18s (Hợp lệ ✓)            │
│  Tiến độ đọc hôm nay: 25 / 90 phút (Nhận: +$1,250 Xu, +5 INT)   │
└─────────────────────────────────────────────────────────────────┘
```

1. **Page Dwell Time Threshold (Tối thiểu 15s/trang):**
   * Mỗi khi lật sang trang mới, một bộ đếm `pageTimer` được kích hoạt.
   * Nếu người dùng lật trang nhanh hơn 15 giây (lướt trang giả tạo) $\rightarrow$ Không tích lũy thời gian đọc.
   * Nếu dừng ở 1 trang quá 5 phút mà không có tương tác chạm $\rightarrow$ Tự động tạm dừng tính giờ (chống bật sáng màn hình bỏ đi).
2. **Keep-Alive Check:**
   * Mỗi 15 phút xuất hiện 1 pop-up chạm nhẹ để xác thực người thật.
3. **Phần thưởng:**
   * Mỗi 10 phút đọc hợp lệ = Cộng ngay **$500 Xu** vào ví + **2 Điểm Trí Tuệ (INT)**.
   * Trần tối đa: 90 phút/ngày để tránh lạm phát kinh tế game.

---

## 4. Mã Nguồn Mẫu Module Reader (Clean Architecture)

### 4.1. Entity Quản lý Sách (`BookEntity`):
```dart
class BookEntity {
  final String id;
  final String title;
  final String author;
  final String filePath; // Đường dẫn trong local documents directory
  final String format; // 'epub' hoặc 'pdf'
  final int totalPages;
  final int lastReadPage;
  final double readProgress; // 0.0 -> 1.0
  final int totalMinutesRead;

  const BookEntity({
    required this.id,
    required this.title,
    required this.author,
    required this.filePath,
    required this.format,
    this.totalPages = 0,
    this.lastReadPage = 1,
    this.readProgress = 0.0,
    this.totalMinutesRead = 0,
  });
}
```

### 4.2. Trình đọc PDF Tối ưu (`PdfReaderView`):
```dart
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

class PdfReaderView extends StatefulWidget {
  final String filePath;
  final int initialPage;
  final Function(int page, int validSeconds) onProgressUpdate;

  const PdfReaderView({
    super.key,
    required this.filePath,
    this.initialPage = 1,
    required this.onProgressUpdate,
  });

  @override
  State<PdfReaderView> createState() => _PdfReaderViewState();
}

class _PdfReaderViewState extends State<PdfReaderView> {
  late PdfControllerPinch _pdfController;
  int _currentPage = 1;
  int _secondsOnCurrentPage = 0;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfControllerPinch(
      document: PdfDocument.openFile(widget.filePath),
      initialPage: widget.initialPage,
    );
  }

  void _onPageChanged(int page) {
    if (_secondsOnCurrentPage >= 15) {
      widget.onProgressUpdate(_currentPage, _secondsOnCurrentPage);
    }
    setState(() {
      _currentPage = page;
      _secondsOnCurrentPage = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F12),
      appBar: AppBar(
        title: PdfPageNumber(
          controller: _pdfController,
          builder: (_, state, page, total) => Text('Trang $page / $total'),
        ),
      ),
      body: PdfViewPinch(
        controller: _pdfController,
        onPageChanged: _onPageChanged,
      ),
    );
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }
}
```
