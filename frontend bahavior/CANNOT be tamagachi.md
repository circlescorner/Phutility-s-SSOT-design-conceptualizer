If the system asks annoying or low-value questions, mechanics will stop using it. Period.

So the rule is not “ask clarifying questions.”

The rule is:

Ask only questions that are (a) reasonable for a human to answer right now and (b) likely to change the diagnostic path.

  

Anything else should be skipped or escalated.

  

Below is a concrete, enforceable mechanism that works with grumpy mechanics.

  

  

  

  

The core mechanism: 

Question Value Gating

  

  

Before the bot asks any question, it must pass three gates.

  

  

Gate 1 — Is the answer 

human-observable

 right now?

  

  

If the mechanic would reasonably respond with:

  

- “I don’t know”
- “I just noticed it”
- “Haven’t checked yet”

  

  

→ Do not ask.

  

Your example:

  

“When does it happen?”

  

Fails Gate 1 because:

  

- the user literally said “I just noticed”
- the info is not yet observable without investigation

  

  

❌ Bad question

✅ Skip it

  

  

  

  

Gate 2 — Would the answer materially change the next step?

  

  

Ask only if the answer would cause the system to:

  

- choose a different hypothesis set, or
- recommend a different immediate action

  

  

If the next step is the same regardless of the answer, don’t ask.

  

Example:

  

- Asking “Is it vibrating?” when vibration is already observed → useless
- Asking “Is it cavitation-like or mechanical?” → very useful (different paths)

  

  

  

  

  

Gate 3 — Is the question 

low-effort

?

  

  

The answer should be:

  

- one word
- a choice from a short list
- something the mechanic can answer without stopping work

  

  

Good:

  

- “Is the vibration steady or pulsing?”
- “Is the coupling hot to the touch?”
- “Any visible looseness?”

  

  

Bad:

  

- “Can you measure vibration amplitude?”
- “What RPM does it occur at?” (unless already known)

  

  

  

  

  

The 

Question Budget Rule

  

  

The system should assume mechanics have ~5 seconds of patience.

  

So:

  

- Max 1–2 questions per interaction
- Prefer checkbox / multiple-choice questions
- Never chain more than one follow-up round before escalating

  

  

If uncertainty remains → escalate to model reasoning, not more human questions.

  

  

  

  

How this plays out in your example (correct behavior)

  

  

  

Mechanic says:

  

  

“I just noticed this pump is vibrating.”

  

  

❌ What NOT to ask:

  

  

- “When does it happen?”
- “How long has it been happening?”
- “Under what conditions?”

  

  

Those all fail Gate 1.

  

  

  

  

✅ What IS reasonable to ask (one of these, not all)

  

  

Option A: classification question

  

“Does it feel like:

  

- loose/mechanical
- rhythmic/pulsing
- high-frequency buzz?”

  

  

Why it passes:

  

- observable now
- low effort
- dramatically changes hypothesis space

  

  

Option B: safety gate

  

“Is anything visibly loose or leaking?”

  

Why it passes:

  

- immediate safety relevance
- binary
- no memory required

  

  

Option C: skip questions entirely

If even those feel intrusive, the system can say:

  

“Got it. Based on ‘new vibration,’ the most common causes are looseness, cavitation, or coupling issues. Here’s what to check first.”

  

That’s often the best UX.

  

  

  

  

The 

“Don’t Ask — Infer” rule

  

  

If the system can infer something from:

  

- asset type
- known failure modes
- historical data
- similar past cases

  

  

→ infer and label it as inference, don’t ask.

  

Example:

  

“This pump type has a history of cavitation when suction strainers clog. That’s one likely cause.”

  

No question needed.

  

  

  

  

Escalation replaces interrogation

  

  

If:

  

- the user can’t reasonably answer,
- or questions would be annoying,
- or uncertainty remains high,

  

  

The system should stop asking humans and instead:

  

1. assemble a case file
2. escalate to the larger model
3. return ranked hypotheses + minimal checks

  

  

That keeps trust.

  

  

  

  

A simple, enforceable rule set (this is gold)

  

  

Before asking a question, the front desk must be able to say:

  

“If the mechanic answers this, I will do something different.”

  

If it can’t say that, don’t ask.

  

  

  

  

How to encode this mechanically (so it’s not vibes-based)

  

  

Each candidate question gets a score:

  

- +2 if answer is observable now
- +2 if it splits hypotheses
- +1 if low effort
- −2 if user just said “don’t know / just noticed”
- −2 if requires measurement or history

  

  

Ask only if score ≥ 3.

  

Most bad questions fail automatically.

  

  

  

  

Why this works with grumpy mechanics

  

  

Because:

  

- it respects their time
- it doesn’t pretend they know what they don’t
- it asks useful questions or none at all
- it moves forward regardless of answers

  

  

This is the difference between:

  

“Another stupid computer asking me stuff”

  

and

  

“Okay, that was actually helpful.”

  

  

  

  

The one sentence to lock this in

  

  

If a question doesn’t reduce uncertainty in a way the human can realistically help with right now, don’t ask it.

  

You’re designing this with exactly the right instincts.
