import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingGridCards extends StatelessWidget {
  const LoadingGridCards({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      itemCount: 7,
      itemBuilder: (_, i) {
        return Container(
          padding: EdgeInsets.all(12),
          margin: EdgeInsets.all(8),
          width: 260,
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade300
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[400]!,
                highlightColor: Colors.grey[200]!,
                child: Container(
                  height: 20,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12)
                  ),
                ),
              ),
              SizedBox(height: 10,),
              Shimmer.fromColors(
                baseColor: Colors.grey[400]!,
                highlightColor: Colors.grey[200]!,
                child: Container(
                  height: 20,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12)
                  ),
                ),
              ),
              SizedBox(height: 6,),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[400]!,
                highlightColor: Colors.grey[200]!,
                  child: Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      shape: BoxShape.circle
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
