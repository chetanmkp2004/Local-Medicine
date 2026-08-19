package com.fintrack.api;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.annotation.DirtiesContext;
import org.springframework.test.web.servlet.MockMvc;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@DirtiesContext(classMode = DirtiesContext.ClassMode.AFTER_EACH_TEST_METHOD)
class ExpenseSplittingIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void equalSplitAmongThreeParticipants() throws Exception {
        createExpense("u1", "Dinner", "120.00", "EQUAL", List.of(
                participant("u1", null), participant("u2", null), participant("u3", null)
        ));

        mockMvc.perform(get("/api/users/u2/balances").header("X-User-Id", "u2"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.balances[0].counterpartUserId").value("u1"))
                .andExpect(jsonPath("$.balances[0].direction").value("YOU_OWE"))
                .andExpect(jsonPath("$.balances[0].amount").value(40.00));
    }

    @Test
    void customSplitWithMatchingTotal() throws Exception {
        createExpense("u1", "Trip", "100.00", "CUSTOM", List.of(
                participant("u1", "20.00"), participant("u2", "30.00"), participant("u3", "50.00")
        ));

        mockMvc.perform(get("/api/users/u3/balances").header("X-User-Id", "u3"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.balances[0].counterpartUserId").value("u1"))
                .andExpect(jsonPath("$.balances[0].direction").value("YOU_OWE"))
                .andExpect(jsonPath("$.balances[0].amount").value(50.00));
    }

    @Test
    void customSplitWithIncorrectSumShouldFail() throws Exception {
        mockMvc.perform(post("/api/expenses")
                        .header("X-User-Id", "u1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "creatorUserId", "u1",
                                "description", "Rent",
                                "totalAmount", "100.00",
                                "splitType", "CUSTOM",
                                "participants", List.of(
                                        participant("u1", "20.00"),
                                        participant("u2", "20.00")
                                )
                        ))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("Custom split amounts must sum exactly to total amount"));
    }

    @Test
    void netBalanceCalculationAcrossMultipleExpenses() throws Exception {
        createExpense("u1", "Dinner", "60.00", "EQUAL", List.of(
                participant("u1", null), participant("u2", null)
        ));
        createExpense("u2", "Taxi", "20.00", "EQUAL", List.of(
                participant("u1", null), participant("u2", null)
        ));

        mockMvc.perform(get("/api/users/u1/balances").header("X-User-Id", "u1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.balances[0].counterpartUserId").value("u2"))
                .andExpect(jsonPath("$.balances[0].direction").value("OWED_TO_YOU"))
                .andExpect(jsonPath("$.balances[0].amount").value(20.00));
    }

    @Test
    void expenseWithSingleParticipantFailsGracefully() throws Exception {
        mockMvc.perform(post("/api/expenses")
                        .header("X-User-Id", "u1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "creatorUserId", "u1",
                                "description", "Solo",
                                "totalAmount", "20.00",
                                "splitType", "EQUAL",
                                "participants", List.of(participant("u1", null))
                        ))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("Shared expense must include at least 2 participants"));
    }

    @Test
    void unauthorizedAccessAttemptReturnsForbidden() throws Exception {
        createExpense("u1", "Lunch", "30.00", "EQUAL", List.of(
                participant("u1", null), participant("u2", null)
        ));

        mockMvc.perform(get("/api/users/u1/balances").header("X-User-Id", "u2"))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.error").value("Unauthorized access to another user's data"));
    }

    private void createExpense(String creator, String description, String total, String splitType, List<Map<String, Object>> participants) throws Exception {
        mockMvc.perform(post("/api/expenses")
                        .header("X-User-Id", creator)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "creatorUserId", creator,
                                "description", description,
                                "totalAmount", total,
                                "splitType", splitType,
                                "participants", participants
                        ))))
                .andExpect(status().isCreated());
    }

    private Map<String, Object> participant(String userId, String shareAmount) {
        Map<String, Object> participant = new HashMap<>();
        participant.put("userId", userId);
        participant.put("shareAmount", shareAmount);
        return participant;
    }
}
