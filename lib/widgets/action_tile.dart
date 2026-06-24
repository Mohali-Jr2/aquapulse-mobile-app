import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class ActionTile extends StatelessWidget {

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return Material(

      color: Colors.transparent,

      child: InkWell(

        borderRadius: BorderRadius.circular(24),

        onTap: onTap,

        child: Container(

          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(

            color: AppColors.card,

            borderRadius:
                BorderRadius.circular(24),

            boxShadow: [

              BoxShadow(

                color:
                    Colors.black.withOpacity(.05),

                blurRadius: 18,

                offset: const Offset(0, 9),
              ),
            ],
          ),

          child: Row(

            children: [

              CircleAvatar(

                backgroundColor:
                    AppColors.aqua.withOpacity(.22),

                child: Icon(
                  icon,
                  color: AppColors.blue,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(

                child: Column(

                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(

                      title,

                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    Text(

                      subtitle,

                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}