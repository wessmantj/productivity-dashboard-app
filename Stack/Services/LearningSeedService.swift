import Foundation
import SwiftData

struct LearningSeedService {

    static func seedIfNeeded(context: ModelContext) {
        guard !UserDefaults.standard.bool(forKey: "learningSeedled") else { return }

        // MARK: — Phase 0
        let p0 = LearningPhase(order: 0, title: "Phase 0 — Math Foundations", durationWeeks: 6, isExpanded: true)
        context.insert(p0)

        let w0_1 = LearningWeek(order: 0, title: "Week 1-3 — Linear Algebra")
        context.insert(w0_1)
        addTopics(to: w0_1, context: context, items: [
            ("Gilbert Strang textbook + MIT 18.06 YouTube", "theory"),
            ("Implement matrix multiplication, Gaussian elimination, dot products, projections, eigendecomposition in raw NumPy", "implementation"),
            ("SVD deep dive — appears in PCA, embeddings, and attention", "theory"),
        ])
        p0.weeks.append(w0_1)

        let w0_2 = LearningWeek(order: 1, title: "Week 4-5 — Probability & Statistics")
        context.insert(w0_2)
        addTopics(to: w0_2, context: context, items: [
            ("DeGroot & Schervish ch. 1–5, or stat88.org", "theory"),
            ("Cover: Gaussian/Bernoulli/Multinomial distributions, Bayes, MLE, expectation, variance", "theory"),
            ("Loss functions = negative log-likelihood. Understand MLE geometrically.", "theory"),
        ])
        p0.weeks.append(w0_2)

        let w0_3 = LearningWeek(order: 2, title: "Week 6 — Multivariable Calculus & Optimization")
        context.insert(w0_3)
        addTopics(to: w0_3, context: context, items: [
            ("MIT 18.02 lecture notes + Boyd & Vandenberghe Convex Optimization ch. 1", "theory"),
            ("Partial derivatives, gradients, chain rule, convexity basics", "theory"),
            ("Backpropagation is just the chain rule. Feel this geometrically.", "theory"),
        ])
        p0.weeks.append(w0_3)

        // MARK: — Phase 1
        let p1 = LearningPhase(order: 1, title: "Phase 1 — DSA Foundations", durationWeeks: 3)
        context.insert(p1)

        let w1_1 = LearningWeek(order: 0, title: "Week 1 — Arrays, Linked Lists, Hash Tables, Stacks, Queues")
        context.insert(w1_1)
        addTopics(to: w1_1, context: context, items: [
            ("CLRS or Sedgewick — implement each from scratch", "implementation"),
            ("Hash tables: implement chaining and open addressing, understand load factor and resizing", "implementation"),
            ("Use visualgo.net to visualize every structure before implementing", "theory"),
        ])
        p1.weeks.append(w1_1)

        let w1_2 = LearningWeek(order: 1, title: "Week 2 — Trees and Graphs")
        context.insert(w1_2)
        addTopics(to: w1_2, context: context, items: [
            ("BST: insert, search, delete, all traversals", "implementation"),
            ("Heaps (priority queues), Graphs: adjacency list and matrix, BFS, DFS, Dijkstra's", "implementation"),
            ("Know Big-O for every operation and why, not just what", "theory"),
        ])
        p1.weeks.append(w1_2)

        let w1_3 = LearningWeek(order: 2, title: "Week 3 — Sorting, Searching, Complexity")
        context.insert(w1_3)
        addTopics(to: w1_3, context: context, items: [
            ("Implement bubble, merge, quicksort. Understand recurrence relations.", "implementation"),
            ("Binary search and variants. Understand O(n log n) physically.", "theory"),
            ("After this: you'll understand why FAISS is fast in terms you can fully articulate.", "milestone"),
        ])
        p1.weeks.append(w1_3)

        // MARK: — Phase 2
        let p2 = LearningPhase(order: 2, title: "Phase 2 — Classical Machine Learning", durationWeeks: 5)
        context.insert(p2)

        let w2_1 = LearningWeek(order: 0, title: "Week 1 — Linear Regression")
        context.insert(w2_1)
        addTopics(to: w2_1, context: context, items: [
            ("Implement with gradient descent AND normal equation — verify they converge", "implementation"),
            ("Understand loss functions geometrically, bias-variance tradeoff, regularization", "theory"),
        ])
        p2.weeks.append(w2_1)

        let w2_2 = LearningWeek(order: 1, title: "Week 2 — Logistic Regression")
        context.insert(w2_2)
        addTopics(to: w2_2, context: context, items: [
            ("Implement from scratch with gradient descent", "implementation"),
            ("Derive why cross-entropy loss is used instead of MSE (MLE argument)", "theory"),
        ])
        p2.weeks.append(w2_2)

        let w2_3 = LearningWeek(order: 2, title: "Week 3 — SVMs and Kernels")
        context.insert(w2_3)
        addTopics(to: w2_3, context: context, items: [
            ("Implement using cvxpy for the optimization", "implementation"),
            ("Kernel trick: implicitly operating in infinite-dimensional feature spaces", "theory"),
        ])
        p2.weeks.append(w2_3)

        let w2_4 = LearningWeek(order: 3, title: "Week 4 — Trees and Ensembles")
        context.insert(w2_4)
        addTopics(to: w2_4, context: context, items: [
            ("Decision trees from scratch — implement information gain and Gini impurity", "implementation"),
            ("Gradient boosting: understand as fitting residuals sequentially", "theory"),
        ])
        p2.weeks.append(w2_4)

        let w2_5 = LearningWeek(order: 4, title: "Week 5 — Unsupervised Learning and PCA")
        context.insert(w2_5)
        addTopics(to: w2_5, context: context, items: [
            ("K-means from scratch. PCA from scratch using eigendecomposition.", "implementation"),
            ("MILESTONE: Complete ML pipeline using only NumPy and raw Python. No sklearn for the model.", "milestone"),
        ])
        p2.weeks.append(w2_5)

        // MARK: — Phase 3
        let p3 = LearningPhase(order: 3, title: "Phase 3 — Deep Learning", durationWeeks: 6)
        context.insert(p3)

        let w3_1 = LearningWeek(order: 0, title: "Weeks 1-2 — Neural Networks and Backpropagation")
        context.insert(w3_1)
        addTopics(to: w3_1, context: context, items: [
            ("Michael Nielsen 'Neural Networks and Deep Learning' (free)", "theory"),
            ("Implement in raw NumPy: forward pass, loss, backward pass, weight updates", "implementation"),
            ("Do NOT use PyTorch yet. This is the most important implementation in the entire plan.", "milestone"),
        ])
        p3.weeks.append(w3_1)

        let w3_2 = LearningWeek(order: 1, title: "Week 3 — Convolutional Networks")
        context.insert(w3_2)
        addTopics(to: w3_2, context: context, items: [
            ("CS231n Stanford lecture notes (free)", "theory"),
            ("Implement a conv layer from scratch in NumPy", "implementation"),
        ])
        p3.weeks.append(w3_2)

        let w3_3 = LearningWeek(order: 2, title: "Week 4 — Training Deep Networks")
        context.insert(w3_3)
        addTopics(to: w3_3, context: context, items: [
            ("Batch norm (Ioffe & Szegedy 2015), Dropout (Srivastava 2014), Adam optimizer", "theory"),
            ("Xavier/He initialization — understand why random init matters geometrically", "theory"),
        ])
        p3.weeks.append(w3_3)

        let w3_4 = LearningWeek(order: 3, title: "Weeks 5-6 — PyTorch Properly")
        context.insert(w3_4)
        addTopics(to: w3_4, context: context, items: [
            ("Rebuild NumPy neural net in PyTorch. Verify manual gradients match autograd exactly.", "implementation"),
            ("Understand computation graphs, what .backward() traverses, DataLoader and batching", "theory"),
        ])
        p3.weeks.append(w3_4)

        // MARK: — Phase 4
        let p4 = LearningPhase(order: 4, title: "Phase 4 — NLP Foundations", durationWeeks: 4)
        context.insert(p4)

        let w4_1 = LearningWeek(order: 0, title: "Week 1 — Language Model Fundamentals")
        context.insert(w4_1)
        addTopics(to: w4_1, context: context, items: [
            ("N-gram models, perplexity. Implement a bigram model from scratch.", "implementation"),
            ("Jurafsky & Martin 'Speech and Language Processing' 3rd ed. (free)", "theory"),
        ])
        p4.weeks.append(w4_1)

        let w4_2 = LearningWeek(order: 1, title: "Week 2 — Word Embeddings")
        context.insert(w4_2)
        addTopics(to: w4_2, context: context, items: [
            ("Implement Word2Vec skip-gram with negative sampling from scratch", "implementation"),
            ("Read Mikolov et al. 2013 — your first real paper", "theory"),
        ])
        p4.weeks.append(w4_2)

        let w4_3 = LearningWeek(order: 2, title: "Week 3 — RNNs and LSTMs")
        context.insert(w4_3)
        addTopics(to: w4_3, context: context, items: [
            ("Implement vanilla RNN from scratch. Work through vanishing gradient math explicitly.", "implementation"),
            ("Implement LSTM cell from scratch: understand each gate and what problem it solves", "implementation"),
        ])
        p4.weeks.append(w4_3)

        let w4_4 = LearningWeek(order: 3, title: "Week 4 — Attention from Scratch")
        context.insert(w4_4)
        addTopics(to: w4_4, context: context, items: [
            ("Read 'Attention Is All You Need' (Vaswani et al. 2017) — every equation", "theory"),
            ("Implement scaled dot-product attention from scratch in NumPy", "implementation"),
            ("Implement a small transformer encoder from scratch", "implementation"),
        ])
        p4.weeks.append(w4_4)

        // MARK: — Phase 5
        let p5 = LearningPhase(order: 5, title: "Phase 5 — LLMs In Depth", durationWeeks: 5)
        context.insert(p5)

        let w5_1 = LearningWeek(order: 0, title: "Weeks 1-2 — GPT Architecture and Pretraining")
        context.insert(w5_1)
        addTopics(to: w5_1, context: context, items: [
            ("Read GPT-1, GPT-2, GPT-3 papers in order", "theory"),
            ("Read Karpathy's nanoGPT repo line by line. Implement it yourself first, then compare.", "implementation"),
        ])
        p5.weeks.append(w5_1)

        let w5_2 = LearningWeek(order: 1, title: "Week 3 — Fine-tuning and LoRA")
        context.insert(w5_2)
        addTopics(to: w5_2, context: context, items: [
            ("Read Hu et al. 2021 (LoRA paper)", "theory"),
            ("Fine-tune a small model using LoRA on Hugging Face on a real task", "implementation"),
        ])
        p5.weeks.append(w5_2)

        let w5_3 = LearningWeek(order: 2, title: "Week 4 — RLHF and Alignment")
        context.insert(w5_3)
        addTopics(to: w5_3, context: context, items: [
            ("Read InstructGPT paper (Ouyang et al. 2022)", "theory"),
            ("Understand SFT, reward model training, PPO optimization, reward hacking failure modes", "theory"),
        ])
        p5.weeks.append(w5_3)

        let w5_4 = LearningWeek(order: 3, title: "Week 5 — Inference and Systems")
        context.insert(w5_4)
        addTopics(to: w5_4, context: context, items: [
            ("KV cache, Quantization (INT8/INT4), Speculative decoding, FlashAttention", "theory"),
        ])
        p5.weeks.append(w5_4)

        // MARK: — Phase 6
        let p6 = LearningPhase(order: 6, title: "Phase 6 — ML Systems and Infrastructure", durationWeeks: 3)
        context.insert(p6)

        let w6_1 = LearningWeek(order: 0, title: "Week 1 — Training Infrastructure")
        context.insert(w6_1)
        addTopics(to: w6_1, context: context, items: [
            ("Distributed training: data parallelism, model parallelism, pipeline parallelism", "theory"),
            ("Read Megatron-LM paper for how large-scale training actually works", "theory"),
        ])
        p6.weeks.append(w6_1)

        let w6_2 = LearningWeek(order: 1, title: "Week 2 — Serving and Deployment")
        context.insert(w6_2)
        addTopics(to: w6_2, context: context, items: [
            ("Vector database internals — HNSW algorithm (what FAISS actually uses)", "theory"),
            ("Model serving patterns, latency vs throughput, dynamic batching", "theory"),
        ])
        p6.weeks.append(w6_2)

        let w6_3 = LearningWeek(order: 2, title: "Week 3 — Evaluation")
        context.insert(w6_3)
        addTopics(to: w6_3, context: context, items: [
            ("RAGAS framework: faithfulness vs relevance vs groundedness as distinct metrics", "theory"),
            ("MILESTONE: Your RAG system comes full circle with complete understanding.", "milestone"),
        ])
        p6.weeks.append(w6_3)

        // MARK: — Reading seed
        let book = ReadingEntry(
            title: "Introduction to Linear Algebra",
            author: "Gilbert Strang",
            totalPages: 500,
            currentPage: 0,
            dailyGoalPages: 20
        )
        context.insert(book)

        UserDefaults.standard.set(true, forKey: "learningSeedled")
    }

    private static func addTopics(to week: LearningWeek, context: ModelContext,
                                  items: [(String, String)]) {
        for (i, (title, type)) in items.enumerated() {
            let topic = LearningTopic(order: i, title: title, topicType: type)
            context.insert(topic)
            week.topics.append(topic)
        }
    }
}
