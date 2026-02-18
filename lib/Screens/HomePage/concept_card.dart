import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nexus/Models/concept_model.dart';
import 'package:nexus/Models/concept_progress_model.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';


class ConceptCard extends StatefulWidget {
  final TopicsData project;
  final ConceptProgress? progress;
  const ConceptCard({super.key, required this.project, this.progress});

  @override
  State<ConceptCard> createState() => _ConceptCardState();
}

class _ConceptCardState extends State<ConceptCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
  double normalizedProgress = 0.0;
  if(widget.progress != null && widget.project.totalSteps > 0 ){
    normalizedProgress = widget.progress!.progress / widget.project.totalSteps;
    normalizedProgress = normalizedProgress.clamp(0.0, 1.0);
  }

   String cleanTitle = widget.project.topicName.split('(').first.trim();

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        width: 260,
        height: 200,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _hovering
                ? [Colors.blueAccent.withOpacity(0.3), Colors.black.withOpacity(0.7)]
                : [Colors.white, Colors.grey.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _hovering ? Colors.blueAccent : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _hovering
                  ? Colors.blueAccent.withOpacity(0.4)
                  : Colors.grey.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cleanTitle,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            
            Padding(
              padding: const EdgeInsets.only(right:8.0),
              child: SizedBox(
                height: 50,
                child: Text(
                  widget.project.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
              ),
            ),

            const SizedBox(height: 12),
            Spacer(),
           
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Iconsax.clock, size: 14, color: Colors.black54),
                const SizedBox(width: 4),
                Text(
                  widget.project.estimatedtime,
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
                Spacer(),
                CircularPercentIndicator(
                  lineWidth: 3,
                  radius: 20,
                  animation: true,
                  percent: normalizedProgress,
                  backgroundColor: Colors.grey.shade300,
                  progressColor: Colors.blueAccent,
                  center:Consumer(builder: (_, provider, _){
                    return  Text(
                    "${(normalizedProgress*100).toStringAsFixed(0)}%",
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  );
                  })
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
