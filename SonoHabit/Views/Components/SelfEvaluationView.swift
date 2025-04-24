import SwiftUI

/// 練習の自己評価を入力するためのビュー
struct SelfEvaluationView: View {
    /// 評価値 (0: 未評価, 1: 悪い, 2: 普通, 3: 良い)
    @Binding var rating: Int
    
    /// 評価表示用のラベル
    private let ratingLabels = ["未評価", "😕", "😐", "🙂"]
    
    /// 評価ごとの色
    private let ratingColors: [Color] = [.gray, .badRating, .neutralRating, .goodRating]
    
    var body: some View {
        VStack(spacing: 10) {
            Text("自己評価")
                .font(.headline)
            
            HStack(spacing: 20) {
                ForEach(1..<ratingLabels.count, id: \.self) { index in
                    Button(action: {
                        withAnimation {
                            rating = index
                        }
                    }) {
                        Text(ratingLabels[index])
                            .font(.system(size: 30))
                            .padding()
                            .background(
                                Circle()
                                    .fill(rating == index ? ratingColors[index] : Color.clear)
                                    .frame(width: 60, height: 60)
                            )
                            .foregroundColor(rating == index ? .white : ratingColors[index])
                            .overlay(
                                Circle()
                                    .stroke(ratingColors[index], lineWidth: 2)
                                    .frame(width: 60, height: 60)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            if rating > 0 {
                Text("評価: \(ratingLabels[rating])")
                    .foregroundColor(ratingColors[rating])
                    .font(.caption)
                    .padding(.top, 5)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

#Preview {
    VStack {
        SelfEvaluationView(rating: .constant(0))
        SelfEvaluationView(rating: .constant(1))
        SelfEvaluationView(rating: .constant(2))
        SelfEvaluationView(rating: .constant(3))
    }
    .padding()
    .background(Color(.systemGroupedBackground))
} 