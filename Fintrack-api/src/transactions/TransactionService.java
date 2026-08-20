package transactions;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

public class TransactionService {
    private static final Map<String, List<Transaction>> db = new HashMap<>();

    public Transaction create(Transaction t) {
        t.id = UUID.randomUUID().toString();
        db.putIfAbsent(t.userId, new ArrayList<>());
        db.get(t.userId).add(t);
        return t;
    }

    public List<Transaction> getByUser(String userId) {
        return db.getOrDefault(userId, new ArrayList<>());
    }

    public void deleteAll() {
        db.clear();
    }
}
