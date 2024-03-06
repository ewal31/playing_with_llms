import time

import dspy

ollama_model = dspy.OllamaLocal(
    model = 'mistral:7b-instruct-v0.2-q6_K',
)

# This sets the language model for DSPy.
dspy.settings.configure(lm=ollama_model)


# An example question
my_example = {
    "question": "What game was Super Mario Bros. 2 based on?",
    "answer": "Doki Doki Panic",
}

# Signature for a simple question answer model.
class BasicQA(dspy.Signature):
    """Answer questions about classic video games."""
    question = dspy.InputField(desc="a question about classic video games")
    answer = dspy.OutputField(desc="often between 1 and 5 words")

# Same as above, but wanted a longer output answer.
class BasicQALongAnswer(dspy.Signature):
    """Answer questions about classic video games."""
    question = dspy.InputField(desc="a question about classic video games")
    answer = dspy.OutputField(desc="Should be at least 50 words")

# Want the answer to be about cats
class BasicQACats(dspy.Signature):
    """Answer questions about classic video games."""
    question = dspy.InputField(desc="a question about classic video games")
    answer = dspy.OutputField(desc="relates to cats")

# Want the answer to be about food
class BasicQAFood(dspy.Signature):
    """Answer questions about classic video games."""
    question = dspy.InputField(desc="a question about classic video games")
    answer = dspy.OutputField(desc="answer with a food")

pred_short = dspy.Predict(BasicQA)(question=my_example['question'])
time.sleep(2)
pred_long = dspy.Predict(BasicQALongAnswer)(question=my_example['question'])
time.sleep(2)
pred_cat = dspy.Predict(BasicQACats)(question=my_example['question'])
time.sleep(2)
pred_food = dspy.Predict(BasicQAFood)(question=my_example['question'])

print("\nThe question is:\n")
print(my_example['question'])
print("")

print("\nShort answer is:\n")
print(pred_short.answer)
print("")

print("\nLong answer is:\n")
print(pred_long.answer)
print("")

print("\nCat based answer is:\n")
print(pred_cat.answer)
print("")

print("\nFood based answer is:\n")
print(pred_food.answer)
print("")
