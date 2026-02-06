import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:travel_app/shared/widgets/app_bar_widget.dart';
import 'package:travel_app/shared/widgets/app_button_widget.dart';
import 'package:travel_app/shared/widgets/app_text_field_widget.dart';

class AddPlanScreen extends StatelessWidget {
  const AddPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: 'Add plan screen',
        icon: CupertinoIcons.xmark,
      ),
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  AppTextFieldWidget(
                    labelText: 'Điểm đến',
                    showLabel: true,
                    hintText: 'Nhập điểm đến (VD: Đà Lạt...)',
                  ),
                  const SizedBox(height: 20),
                  AppTextFieldWidget(
                    labelText: 'Tên chuyến đi',
                    showLabel: true,
                    hintText: 'VD: Vi vu mùa hè',
                  ),
                  const SizedBox(height: 20),
                  AppTextFieldWidget(
                    labelText: 'Thời gian',
                    showLabel: true,
                    suffixIcon: Icon(
                      CupertinoIcons.calendar,
                      color: Color(0xFFFFAD35),
                    ),
                  ),
                  const SizedBox(height: 20),
                  AppTextFieldWidget(
                    labelText: 'Ngân sách dự tính',
                    showLabel: true,
                    hintText: 'Nhập số tiền (VD: 500.000, 1.000.000)',
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Đồng hành cùng',
                      style: GoogleFonts.beVietnamPro(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        // Nút Add
                        GestureDetector(
                          onTap: () {
                            // TODO: mở màn chọn bạn bè / thêm đồng hành
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFFFFAD35),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Add',
                              style: GoogleFonts.beVietnamPro(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 2 avatar stack chồng lên nhau
                        SizedBox(
                          width: 60,
                          height: 44,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Color(0xFFFFAD35),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.white.withValues(
                                      alpha: 0.2,
                                    ),
                                    child: CircleAvatar(
                                      radius: 18,
                                      backgroundImage: NetworkImage(
                                        'https://i.pravatar.cc/100?img=1',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 16,
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Color(0xFFFFAD35),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.white.withValues(
                                      alpha: 0.2,
                                    ),
                                    child: CircleAvatar(
                                      radius: 18,
                                      backgroundImage: NetworkImage(
                                        'https://i.pravatar.cc/100?img=2',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // Nút Lên kế hoạch ngay cố định dưới
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: AppButtonWidget(
              buttonText: 'Lên kế hoạch ngay',
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
