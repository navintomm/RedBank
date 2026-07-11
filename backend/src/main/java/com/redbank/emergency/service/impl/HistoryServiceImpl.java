package com.redbank.emergency.service.impl;

import com.redbank.emergency.dto.EmergencyRequestHistoryDTO;
import com.redbank.emergency.mapper.EmergencyRequestMapper;
import com.redbank.emergency.repository.EmergencyRequestHistoryRepository;
import com.redbank.emergency.service.HistoryService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class HistoryServiceImpl implements HistoryService {

    private final EmergencyRequestHistoryRepository historyRepository;
    private final EmergencyRequestMapper mapper;

    @Override
    public List<EmergencyRequestHistoryDTO> getHistory(UUID requestId) {
        log.info("Fetching history for request {}", requestId);
        return historyRepository.findByRequestIdOrderByCreatedAtAsc(requestId)
                .stream()
                .map(mapper::toHistoryDTO)
                .collect(Collectors.toList());
    }
}
