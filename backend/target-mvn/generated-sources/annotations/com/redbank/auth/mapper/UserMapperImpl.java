package com.redbank.auth.mapper;

import com.redbank.auth.dto.UserDto;
import com.redbank.auth.entity.User;
import java.util.Set;
import java.util.UUID;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2026-07-11T11:13:33+0530",
    comments = "version: 1.5.5.Final, compiler: javac, environment: Java 17.0.12 (Oracle Corporation)"
)
@Component
public class UserMapperImpl implements UserMapper {

    @Override
    public UserDto toDto(User user) {
        if ( user == null ) {
            return null;
        }

        Set<String> roles = null;
        UUID id = null;
        String phoneNumber = null;
        String firstName = null;
        String lastName = null;

        roles = mapRolesToStrings( user.getRoles() );
        id = user.getId();
        phoneNumber = user.getPhoneNumber();
        firstName = user.getFirstName();
        lastName = user.getLastName();

        UserDto userDto = new UserDto( id, phoneNumber, firstName, lastName, roles );

        return userDto;
    }
}
